// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {Uniswap, ISwapRouter} from "src/Uniswap.sol";
import {Balancer} from "src/Balancer.sol";
import {Curve} from "src/Curve.sol";
import {Test, console2} from "forge-std/Test.sol";

contract Zapper is Uniswap, Curve, Balancer, Test {
    using SafeTransferLib for ERC20;

    mapping(address => bool) public allowedTokens;
    mapping(address => uint256) public fees;

    address public aura = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
    address public cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    constructor(ISwapRouter uniRouter) Uniswap(uniRouter) {}

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
}
