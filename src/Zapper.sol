// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

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
    mapping(address => uint256) public fees;

    address public constant WAR = 0xa8258deE2a677874a48F5320670A869D74f0cbC1;

    address warMinter = 0x144a689A8261F1863c89954930ecae46Bd950341;
    address warStaker = 0xA86c53AF3aadF20bE5d7a8136ACfdbC4B074758A;

    event Zapped(address indexed token, uint256 amount, uint256 mintedAmount);


    function enableToken(address token, uint256 fee) external {
        if (token == address(0)) revert("Zero Address");
        // TODO refactor this with mappings for gas and flexibility
        if (fee != 100 && fee != 500 && fee != 3000 && fee != 10_000) revert("Invalid fee");

        allowedTokens[token] = true;
        fees[token] = fee;

        _resetUniswapAllowance(token);
    }

    function disableToken(address token) external {
        allowedTokens[token] = false;

        _removeUniswapAllowance(token);
    }

    function resetWarlordAllowances() external {
        ERC20(aura).safeApprove(warMinter, type(uint256).max);
        ERC20(war).safeApprove(warStaker, type(uint256).max);
    }

    function removeWarlordAllowances() external {
        ERC20(aura).safeApprove(warMinter, 0);
        ERC20(war).safeApprove(warStaker, 0);
    }

    function swapAndZap(address token, uint256 amount, address receiver, uint256 ratio) public returns (uint256) {
        if (token == address(0)) revert("Zero address");
        if (receiver == address(0)) revert("Zero address");
        if (amount == 0) revert("Zero value");
        if (!allowedTokens[token]) revert("Token is not allowed");

        ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (token != WETH) {
            // TODO handle slippage
            amount = _etherize(token, amount, 0);
        }

        if (ratio == 0) {
            _wethToAura(amount, 0);
        } else if (ratio == 10_000) {
            _wethToCvx(amount, 0);
        } else {
            revert("Mixed ratio not implemented yet");
            // TODO compute ratio
            //
            // ethToAura(amount * ratio)
            // ethToCvx(1 - (amount * ratio))
        }
        // uint256 auraAmount = ERC20(aura).balanceOf(address(this));
        // uint256 cvxAmount = ERC20(cvx).balanceOf(address(this));

        // TODO add zap logic

        // TODO should return the amount of staked war
        return 0;
    }

    function _mintAndStake(address token, uint256 amount) internal {}

    function zapThroughSingleToken(address token, uint256 amount, address receiver, bool useCvx)
        external
        returns (uint256)
    {
        if (token == address(0)) revert("Zero address");
        if (receiver == address(0)) revert("Zero address");
        if (amount == 0) revert("Zero value");

        ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (token != WETH) {
            // TODO handle slippage
            amount = _etherize(token, amount, 0);
        }

        if (useCvx) {
            _wethToCvx(amount, 0);
            uint256 cvxAmount = ERC20(cvx).balanceOf(address(this));
            IWarMinter(warMinter).mint(cvx, cvxAmount);
        } else {
            _wethToAura(amount, 0);
            uint256 auraAmount = ERC20(aura).balanceOf(address(this));
            IWarMinter(warMinter).mint(aura, auraAmount);
        }

        uint256 warAmount = ERC20(war).balanceOf(address(this));
        uint256 stakedAmount = IWarStaker(warStaker).stake(warAmount, receiver);

        emit Zapped(token, amount, stakedAmount);
        return stakedAmount;
    }
}
