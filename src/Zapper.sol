// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {Uniswap, ISwapRouter} from "src/Uniswap.sol";
import {Balancer} from "src/Balancer.sol";
import {Curve} from "src/Curve.sol";

contract Zapper is Uniswap, Curve, Balancer {
    using SafeTransferLib for ERC20;

    mapping(address => bool) public allowedTokens;
    mapping(address => uint256) public fees;

    constructor(ISwapRouter uniRouter) Uniswap(uniRouter) {}

    function enableToken(address token, uint256 fee) external {
        if (token != address(0)) revert("Zero Address");
        if (fee != 100 && fee != 500 && fee != 3000 && fee != 10_000) revert("Invalid fee");

        allowedTokens[token] = true;
        fees[token] = fee;

        _approveSwapper(token);
    }

    function disableToken(address token) external {
        allowedTokens[token] = false;
    }

    function swapAndZap(address token, uint256 amount, address receiver, uint256 ratio) public {
        if (token == address(0)) revert("Zero address");
        if (receiver == address(0)) revert("Zero address");
        if (amount == 0) revert("Zero value");
        if (!allowedTokens[token]) revert("Token is not allowed");

        ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (token != WETH) {
            // TODO handle slippage
            _etherize(token, amount, 0);
        }
        if (ratio == 0) {
            _ethToAura(amount);
        } else if (ratio == 10_000) {
            _ethToCvx(amount);
        } else {
            // TODO compute ratio
            //
            // ethToAura(amount * ratio)
            // ethToCvx(1 - (amount * ratio))
        }
    }
}
