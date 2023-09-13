// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Errors} from "src/Errors.sol";
import {ISwapRouter} from "uniswap/ISwapRouter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {EtherUtils} from "src/EtherUtils.sol";

abstract contract AUniswap is EtherUtils {
    using SafeTransferLib for ERC20;

    mapping(address => uint24) public uniswapFees;
    ISwapRouter public swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    event SetUniswapRouter(address newRouter);
    event SetUniswapFee(address indexed token, uint24 fee);

    function setUniswapRouter(address _swapRouter) external onlyOwner {
        if (_swapRouter == address(0)) revert Errors.ZeroAddress();
        swapRouter = ISwapRouter(_swapRouter);

        emit SetUniswapRouter(_swapRouter);
    }

    function _setUniswapFee(address token, uint24 fee) internal {
        uniswapFees[token] = fee;

        emit SetUniswapFee(token, fee);
    }

    function _resetUniswapAllowance(address token) internal {
        ERC20(token).safeApprove(address(swapRouter), type(uint256).max);
    }

    function _removeUniswapAllowance(address token) internal {
        ERC20(token).safeApprove(address(swapRouter), 0);
    }

    function _etherize(address token, uint256 amountIn, uint256 ethOutMin, uint24 fee)
        internal
        returns (uint256 amountOut)
    {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: token, // The input token address
            tokenOut: WETH, // The token received should be Wrapped Ether
            fee: fee, // The fee tier of the pool
            recipient: address(this), // Receiver of the swapped tokens
            deadline: block.timestamp, // Swap has to be terminated at block time
            amountIn: amountIn, // The exact amount to swap
            amountOutMinimum: ethOutMin, // Quote is given by frontend to ensure slippage is minimised
            sqrtPriceLimitX96: 0 // Ensure we swap our exact input amount.
        });

        amountOut = swapRouter.exactInputSingle(params);
    }
}
