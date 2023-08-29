// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ISwapRouter} from "uniswap/ISwapRouter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

abstract contract Uniswap {
    using SafeTransferLib for ERC20;

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    ISwapRouter public immutable swapRouter;
    uint24 public constant poolFee = 500;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    function _approveSwapper(address token) internal {
        ERC20(token).safeApprove(address(swapRouter), type(uint256).max);
    }

    // TODO add function to reset approval in case of hacks
    // TODO should the swap router have a setter?
    // TODO make setter for fee

    function _etherize(address token, uint256 amountIn, uint256 ethOutMin) internal returns (uint256 amountOut) {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: token, // The input token address
            tokenOut: WETH, // The token received should be Wrapped Ether
            fee: poolFee, // The fee tier of the pool
            recipient: msg.sender, // Receiver of the swapped tokens
            deadline: block.timestamp, // Swap has to be terminated at block time
            amountIn: amountIn, // The exact amount to swap
            amountOutMinimum: ethOutMin, // Quote is given by frontend to ensure slippage is minimised
            sqrtPriceLimitX96: 0 // Ensure we swap our exact input amount.
        });

        amountOut = swapRouter.exactInputSingle(params);
    }
}
