// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Errors} from "src/Errors.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {AUniswap, ISwapRouter} from "src/AUniswap.sol";
import {ABalancer} from "src/ABalancer.sol";
import {ACurve} from "src/ACurve.sol";
import {IWarMinter} from "warlord/IWarMinter.sol";
import {IWarStaker} from "warlord/IWarStaker.sol";
import {WETH9} from "int/WETH.sol";

/// @title Warlord Zapper Contract
/// @author centonze.eth
/// @dev This contract enables users to seamlessly convert any pair that is sufficiently liquid on Uniswap V3
/// into stkWar tokens for the Warlord protocol by Paladin.vote. The conversion route is designed as:
/// anyToken -> WETH (via Uniswap) -> either AURA or CVX based on the selected vlToken.
contract Zapper is AUniswap, ACurve, ABalancer {
    using SafeTransferLib for ERC20;

    // Tokens that are whitelisted for zap
    mapping(address => bool) public allowedTokens;

    // Represent 100% of something when calculating ratios
    uint256 private constant MAX_BPS = 10_000;

    // the address of the WAR token
    address public constant WAR = 0xa8258deE2a677874a48F5320670A869D74f0cbC1;

    // Contract allowed to mint war
    address public warMinter = 0x144a689A8261F1863c89954930ecae46Bd950341;
    // Contract allowed to stake war and obtain rewards
    address public warStaker = 0xA86c53AF3aadF20bE5d7a8136ACfdbC4B074758A;

    /// @notice This event is emitted when a zap operation occurs.
    /// @param token The token that was zapped.
    /// @param amount The amount of token that was zapped.
    /// @param mintedAmount The amount of WAR tokens minted as a result.
    /// @param receiver The address of the recipient of the WAR tokens.
    event Zapped(address indexed token, uint256 amount, uint256 mintedAmount, address receiver);

    /// @notice This event is emitted when a token's whitelist is updated.
    /// @param token The token that had its status updated.
    /// @param allowed True if the token is now allowed, false otherwise.
    event TokenUpdated(address indexed token, bool allowed);

    /// @notice This event is emitted when the WarMinter address is changed.
    /// @param newMinter The new WarMinter address.
    event SetWarMinter(address newMinter);

    /// @notice This event is emitted when the WarStaker address is changed.
    /// @param newStaker The new WarStaker address.
    event SetWarStaker(address newStaker);

    /*////////////////////////////////////////////
    /              Tokens Management             /
    ////////////////////////////////////////////*/

    /// @dev Enables a token for zapping and sets the Uniswap V3 fee when swapping to ether.
    /// @param token The token to be enabled.
    /// @param fee The Uniswap pool fee.
    function enableToken(address token, uint24 fee) external onlyOwner {
        // Not checking the fee tier correctness for simplicity
        // because new ones might be added by uniswap governance.
        if (token == address(0)) revert Errors.ZeroAddress();
        if (allowedTokens[token]) revert Errors.TokenAlreadyAllowed();

        allowedTokens[token] = true;
        _setUniswapFee(token, fee);

        _resetUniswapAllowance(token);

        emit TokenUpdated(token, true);
    }

    /// @dev Updates the Uniswap fee associated with a token.
    /// @param token The token for which the fee is being set.
    /// @param fee The new fee value.
    function setUniswapFee(address token, uint24 fee) external onlyOwner {
        // Not checking the fee tier correctness for simplicity
        // because new ones might be added by uniswap governance.
        if (token == address(0)) revert Errors.ZeroAddress();
        if (!allowedTokens[token]) revert Errors.TokenNotAllowed();

        _setUniswapFee(token, fee);
    }

    /// @dev Disables a token from being used in zapping operations.
    /// @notice Can also be used to remove allowance to uniswap router for that token.
    /// @param token The token to be disabled.
    function disableToken(address token) external onlyOwner {
        if (token == address(0)) revert Errors.ZeroAddress();

        allowedTokens[token] = false;

        _removeUniswapAllowance(token);

        emit TokenUpdated(token, false);
    }

    /*////////////////////////////////////////////
    /          Warlord allowance methods         /
    ////////////////////////////////////////////*/

    /// @dev Resets the allowances for Warlord-related interactions.
    function resetWarlordAllowances() external onlyOwner {
        ERC20(AURA).safeApprove(warMinter, type(uint256).max);
        ERC20(CVX).safeApprove(warMinter, type(uint256).max);
        ERC20(WAR).safeApprove(warStaker, type(uint256).max);
    }

    /// @dev Removes the allowances for Warlord-related interactions.
    function removeWarlordAllowances() external onlyOwner {
        ERC20(AURA).safeApprove(warMinter, 0);
        ERC20(CVX).safeApprove(warMinter, 0);
        ERC20(WAR).safeApprove(warStaker, 0);
    }

    /*////////////////////////////////////////////
    /              Warlord setters               /
    ////////////////////////////////////////////*/

    /// @dev Changes the WarMinter contract address.
    /// @param _warMinter The new WarMinter contract address.
    function setWarMinter(address _warMinter) external onlyOwner {
        if (_warMinter == address(0)) revert Errors.ZeroAddress();
        warMinter = _warMinter;

        emit SetWarMinter(_warMinter);
    }

    /// @dev Changes the WarStaker contract address.
    /// @param _warStaker The new WarStaker contract address.
    function setWarStaker(address _warStaker) external onlyOwner {
        if (_warStaker == address(0)) revert Errors.ZeroAddress();
        warStaker = _warStaker;

        emit SetWarStaker(_warStaker);
    }

    /*////////////////////////////////////////////
    /                Zap Functions               /
    ////////////////////////////////////////////*/

    /// @notice Internal function to zap WETH into a single token, either AURA or CVX, and then mint and stake WAR tokens.
    /// @param receiver The address to receive staked WAR tokens.
    /// @param useCvx A boolean to decide whether to zap into CVX (true) or AURA (false).
    /// @param amount The amount of WETH to be zapped.
    /// @param minVlTokenOut Minimum amount of AURA/CVX expected to receive from zapping.
    /// @return Returns the amount of WAR staked.
    function _zapWethToSingleToken(address receiver, bool useCvx, uint256 amount, uint256 minVlTokenOut)
        internal
        returns (uint256)
    {
        if (useCvx) {
            _wethToCvx(amount, minVlTokenOut);
            uint256 cvxAmount = ERC20(CVX).balanceOf(address(this));
            IWarMinter(warMinter).mint(CVX, cvxAmount);
        } else {
            _wethToAura(amount, minVlTokenOut);
            uint256 auraAmount = ERC20(AURA).balanceOf(address(this));
            IWarMinter(warMinter).mint(AURA, auraAmount);
        }

        uint256 warAmount = ERC20(WAR).balanceOf(address(this));
        return IWarStaker(warStaker).stake(warAmount, receiver);
    }

    /// @notice Zap Ether into a single token (either AURA or CVX) and then mint and stake WAR tokens.
    /// @param receiver The address to receive staked WAR tokens.
    /// @param useCvx A boolean to decide whether to zap into CVX (true) or AURA (false).
    /// @param minVlTokenOut Minimum amount of AURA/CVX expected to receive from zapping.
    /// @return stakedAmount Amount of WAR staked.
    function zapEtherToSingleToken(address receiver, bool useCvx, uint256 minVlTokenOut)
        external
        payable
        returns (uint256 stakedAmount)
    {
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (msg.value == 0) revert Errors.NullAmount();

        // Convert native eth to weth
        WETH9(WETH).deposit{value: msg.value}();

        // Zap weth to vlCvx or vlAura
        stakedAmount = _zapWethToSingleToken(receiver, useCvx, msg.value, minVlTokenOut);

        emit Zapped(WETH, msg.value, stakedAmount, receiver);
    }

    /// @notice Zap a specified ERC20 token into a single token (either AURA or CVX) and then mint and stake WAR tokens.
    /// @param token The ERC20 token to be zapped.
    /// @param amount The amount of the ERC20 token to be zapped.
    /// @param receiver The address to receive staked WAR tokens.
    /// @param useCvx A boolean to decide whether to zap into CVX (true) or AURA (false).
    /// @param minEthOut Minimum amount of WETH expected to receive from token -> WETH conversion.
    /// @param minVlTokenOut Minimum amount of AURA/CVX expected to receive from WETH -> AURA/CVX conversion.
    /// @return stakedAmount Amount of WAR staked.
    function zapERC20ToSingleToken(
        address token,
        uint256 amount,
        address receiver,
        bool useCvx,
        uint256 minEthOut,
        uint256 minVlTokenOut
    ) external returns (uint256 stakedAmount) {
        if (token == address(0)) revert Errors.ZeroAddress();
        if (!allowedTokens[token]) revert Errors.TokenNotAllowed();
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.NullAmount();

        // Pull ether from sender to this contract
        ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Ensure that we have WETH to zap
        if (token != WETH) {
            amount = _etherize(token, amount, minEthOut, uniswapFees[token]);
        }

        // Zap weth to vlCvx or vlAura
        stakedAmount = _zapWethToSingleToken(receiver, useCvx, amount, minVlTokenOut);

        emit Zapped(token, amount, stakedAmount, receiver);
    }

    /// @notice Internal function to zap WETH into multiple tokens (both AURA and CVX), and then mint and stake WAR tokens.
    /// @param receiver The address to receive staked WAR tokens.
    /// @param amount The amount of WETH to be zapped.
    /// @param ratio Ratio of WETH to be used for AURA vs CVX.
    /// @param minAuraOut Minimum amount of AURA expected to receive.
    /// @param minCvxOut Minimum amount of CVX expected to receive.
    /// @return Returns the amount of WAR staked.
    function _zapWethToMultipleTokens(
        address receiver,
        uint256 amount,
        uint256 ratio,
        uint256 minAuraOut,
        uint256 minCvxOut
    ) internal returns (uint256) {
        uint256 auraAmount = amount * ratio / MAX_BPS;
        uint256 cvxAmount = amount - auraAmount;

        _wethToAura(auraAmount, minAuraOut);
        _wethToCvx(cvxAmount, minCvxOut);

        address[] memory vlTokens = new address[](2);
        vlTokens[0] = AURA;
        vlTokens[1] = CVX;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = ERC20(AURA).balanceOf(address(this));
        amounts[1] = ERC20(CVX).balanceOf(address(this));

        IWarMinter(warMinter).mintMultiple(vlTokens, amounts);

        uint256 warAmount = ERC20(WAR).balanceOf(address(this));
        return IWarStaker(warStaker).stake(warAmount, receiver);
    }

    /// @notice Zap Ether into multiple tokens (both AURA and CVX) and then mint and stake WAR tokens.
    /// @param receiver The address to receive staked WAR tokens.
    /// @param ratio Ratio of Ether to be used for AURA vs CVX.
    /// @param minAuraOut Minimum amount of AURA expected to receive.
    /// @param minCvxOut Minimum amount of CVX expected to receive.
    /// @return stakedAmount Amount of WAR staked.
    function zapEtherToMultipleTokens(address receiver, uint256 ratio, uint256 minAuraOut, uint256 minCvxOut)
        external
        payable
        returns (uint256 stakedAmount)
    {
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (ratio == 0 || ratio > 9999) revert Errors.InvalidRatio();
        if (msg.value == 0) revert Errors.NullAmount();

        // Convert native eth to weth
        WETH9(WETH).deposit{value: msg.value}();

        // Zap weth to vlCvx and vlAura
        stakedAmount = _zapWethToMultipleTokens(receiver, msg.value, ratio, minAuraOut, minCvxOut);

        emit Zapped(WETH, msg.value, stakedAmount, receiver);
    }

    /// @notice Zap a specified ERC20 token into multiple tokens (both AURA and CVX) and then mint and stake WAR tokens.
    /// @param token The ERC20 token to be zapped.
    /// @param amount The amount of the ERC20 token to be zapped.
    /// @param receiver The address to receive staked WAR tokens.
    /// @param ratio Ratio of token amount to be used for AURA vs CVX.
    /// @param minEthOut Minimum amount of WETH expected to receive from token -> WETH conversion.
    /// @param minAuraOut Minimum amount of AURA expected to receive from WETH -> AURA conversion.
    /// @param minCvxOut Minimum amount of CVX expected to receive from WETH -> CVX conversion.
    /// @return stakedAmount Amount of WAR staked.
    function zapERC20ToMultipleTokens(
        address token,
        uint256 amount,
        address receiver,
        uint256 ratio,
        uint256 minEthOut,
        uint256 minAuraOut,
        uint256 minCvxOut
    ) external returns (uint256 stakedAmount) {
        if (token == address(0)) revert Errors.ZeroAddress();
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.NullAmount();
        if (!allowedTokens[token]) revert Errors.TokenNotAllowed();
        if (ratio == 0 || ratio > 9999) revert Errors.InvalidRatio();

        // Pull ether from sender to this contract
        ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Ensure that we have WETH to zap
        if (token != WETH) {
            amount = _etherize(token, amount, minEthOut, uniswapFees[token]);
        }

        // Zap weth to vlCvx and vlAura
        stakedAmount = _zapWethToMultipleTokens(receiver, amount, ratio, minAuraOut, minCvxOut);

        emit Zapped(token, amount, stakedAmount, receiver);
    }
}
