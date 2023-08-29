// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ISwapRouter} from "uniswap/ISwapRouter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {EtherUtils} from "src/EtherUtils.sol";

abstract contract Uniswap is EtherUtils {
    using SafeTransferLib for ERC20;

    ISwapRouter private swapRouter;
    uint24 public constant poolFee = 500;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    function setRouter(address _swapRouter) external {
        swapRouter = ISwapRouter(_swapRouter);
    }

    function _resetUniswapAllowance(address token) internal {
        ERC20(token).safeApprove(address(swapRouter), type(uint256).max);
    }

    function _removeUniswapAllowance(address token) internal {
        ERC20(token).safeApprove(address(swapRouter), 0);
        // TODO in case of hacks, might be even worth it to make it disable all the whitelisted tokens automatically
    }

    // TODO should the swap router have a setter?
    // TODO make setter for fee

    function _etherize(address token, uint256 amountIn, uint256 ethOutMin) internal returns (uint256 amountOut) {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: token, // The input token address
            tokenOut: WETH, // The token received should be Wrapped Ether
            fee: poolFee, // The fee tier of the pool
            recipient: address(this), // Receiver of the swapped tokens
            deadline: block.timestamp, // Swap has to be terminated at block time
            amountIn: amountIn, // The exact amount to swap
            amountOutMinimum: ethOutMin, // Quote is given by frontend to ensure slippage is minimised
            sqrtPriceLimitX96: 0 // Ensure we swap our exact input amount.
        });

        amountOut = swapRouter.exactInputSingle(params);
    }
}
