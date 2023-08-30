// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Errors} from "src/Errors.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {Uniswap, ISwapRouter} from "src/Uniswap.sol";
import {Balancer} from "src/Balancer.sol";
import {Curve} from "src/Curve.sol";
import {IWarMinter} from "warlord/IWarMinter.sol";
import {IWarStaker} from "warlord/IWarStaker.sol";
import {Test, console2} from "forge-std/Test.sol";

contract Zapper is Uniswap, Curve, Balancer, Test {
    using SafeTransferLib for ERC20;

    mapping(address => bool) public allowedTokens;
    mapping(address => uint24) public fees;

    address public constant WAR = 0xa8258deE2a677874a48F5320670A869D74f0cbC1;

    address public warMinter = 0x144a689A8261F1863c89954930ecae46Bd950341;
    address public warStaker = 0xA86c53AF3aadF20bE5d7a8136ACfdbC4B074758A;

    event Zapped(address indexed token, uint256 amount, uint256 mintedAmount);

    /*////////////////////////////////////////////
    /              Tokens Management             /
    ////////////////////////////////////////////*/

    function enableToken(address token, uint24 fee) external onlyOwner {
        // Not checking the fee tier correctness for simplicity
        // because new ones might be added by uniswap governance.
        if (token == address(0)) revert Errors.ZeroAddress();

        allowedTokens[token] = true;
        fees[token] = fee;

        _resetUniswapAllowance(token);
    }

    function setFee(address token, uint24 fee) external onlyOwner {
        // Not checking the fee tier correctness for simplicity
        // because new ones might be added by uniswap governance.
        if (!allowedTokens[token]) revert Errors.TokenNotAllowed();

        fees[token] = fee;
    }

    function disableToken(address token) external onlyOwner {
        allowedTokens[token] = false;

        _removeUniswapAllowance(token);
    }

    /*////////////////////////////////////////////
    /              Allowance methods             /
    ////////////////////////////////////////////*/

    function resetWarlordAllowances() external onlyOwner {
        ERC20(AURA).safeApprove(warMinter, type(uint256).max);
        ERC20(CVX).safeApprove(warMinter, type(uint256).max);
        ERC20(WAR).safeApprove(warStaker, type(uint256).max);
    }

    function removeWarlordAllowances() external onlyOwner {
        ERC20(AURA).safeApprove(warMinter, 0);
        ERC20(CVX).safeApprove(warMinter, 0);
        ERC20(WAR).safeApprove(warStaker, 0);
    }

    /*////////////////////////////////////////////
    /              Warlord setters               /
    ////////////////////////////////////////////*/

    function setWarMinter(address _warMinter) external onlyOwner {
        if (_warMinter == address(0)) revert Errors.ZeroAddress();
        warMinter = _warMinter;
    }

    function setWarStaker(address _warStaker) external onlyOwner {
        if (_warStaker == address(0)) revert Errors.ZeroAddress();
        warStaker = _warStaker;
    }

    /*////////////////////////////////////////////
    /                Zap Functions               /
    ////////////////////////////////////////////*/

    function zapThroughSingleToken(address token, uint256 amount, address receiver, bool useCvx)
        external
        returns (uint256 stakedAmount)
    {
        if (token == address(0)) revert Errors.ZeroAddress();
        if (!allowedTokens[token]) revert Errors.TokenNotAllowed();
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.NullAmount();

        ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (token != WETH) {
            // TODO handle slippage
            amount = _etherize(token, amount, 0, fees[token]);
        }

        if (useCvx) {
            _wethToCvx(amount, 0);
            uint256 cvxAmount = ERC20(CVX).balanceOf(address(this));
            IWarMinter(warMinter).mint(CVX, cvxAmount);
        } else {
            _wethToAura(amount, 0);
            uint256 auraAmount = ERC20(AURA).balanceOf(address(this));
            IWarMinter(warMinter).mint(AURA, auraAmount);
        }

        uint256 warAmount = ERC20(WAR).balanceOf(address(this));
        stakedAmount = IWarStaker(warStaker).stake(warAmount, receiver);

        emit Zapped(token, amount, stakedAmount);
    }

    function zapThroughMultipleTokens(address token, uint256 amount, address receiver, uint256 ratio)
        external
        returns (uint256 stakedAmount)
    {
        if (token == address(0)) revert Errors.ZeroAddress();
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.NullAmount();
        if (!allowedTokens[token]) revert Errors.TokenNotAllowed();
        if (ratio == 0 || ratio > 9999) revert Errors.InvalidRatio();

        ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (token != WETH) {
            // TODO handle slippage
            amount = _etherize(token, amount, 0, fees[token]);
        }

        // Aura amount
        uint256 auraAmount = amount * ratio / 10_000;
        // Cvx amount
        uint256 cvxAmount = amount - auraAmount;

        _wethToAura(auraAmount, 0);
        _wethToCvx(cvxAmount, 0);

        address[] memory vlTokens = new address[](2);
        vlTokens[0] = AURA;
        vlTokens[1] = CVX;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = ERC20(AURA).balanceOf(address(this));
        amounts[1] = ERC20(CVX).balanceOf(address(this));

        IWarMinter(warMinter).mintMultiple(vlTokens, amounts);

        uint256 warAmount = ERC20(WAR).balanceOf(address(this));
        stakedAmount = IWarStaker(warStaker).stake(warAmount, receiver);

        emit Zapped(token, amount, stakedAmount);
    }
}
