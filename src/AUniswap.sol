// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Errors} from "src/Errors.sol";
import {ISwapRouter} from "uniswap/ISwapRouter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {EtherUtils} from "src/EtherUtils.sol";

/// @title AUniswap
/// @author centonze.eth
/// @notice Utility functions related to Uniswap operations.
abstract contract AUniswap is EtherUtils {
    using SafeTransferLib for ERC20;

    // The uniswap pool fee for each token.
    mapping(address => uint24) public uniswapFees;
    // Address of Uniswap V3 router
    ISwapRouter public swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    /// @notice Emitted when the Uniswap router address is updated.
    /// @param newRouter The address of the new router.
    event SetUniswapRouter(address newRouter);

    /// @notice Emitted when the Uniswap fee for a token is updated.
    /// @param token The token whose fee has been updated.
    /// @param fee The new fee value.
    event SetUniswapFee(address indexed token, uint24 fee);

    /// @notice Sets a new address for the Uniswap router.
    /// @param _swapRouter The address of the new router.
    function setUniswapRouter(address _swapRouter) external onlyOwner {
        if (_swapRouter == address(0)) revert Errors.ZeroAddress();
        swapRouter = ISwapRouter(_swapRouter);

        emit SetUniswapRouter(_swapRouter);
    }

    /// @dev Internal function to set Uniswap fee for a token.
    /// @param token The token for which to set the fee.
    /// @param fee The fee to be set.
    function _setUniswapFee(address token, uint24 fee) internal {
        uniswapFees[token] = fee;

        emit SetUniswapFee(token, fee);
    }

    /// @dev Resets allowance for the Uniswap router for a specific token.
    /// @param token The token for which to reset the allowance.
    function _resetUniswapAllowance(address token) internal {
        ERC20(token).safeApprove(address(swapRouter), type(uint256).max);
    }

    /// @dev Removes allowance for the Uniswap router for a specific token.
    /// @param token The token for which to remove the allowance.
    function _removeUniswapAllowance(address token) internal {
        ERC20(token).safeApprove(address(swapRouter), 0);
    }

    function _etherize(address token, uint256 amountIn, uint256 ethOutMin, uint24 fee)
    /// @dev Converts a given amount of a token into WETH using Uniswap.
    /// @param token The token to be converted.
    /// @param amountIn The amount of token to be swapped.
    /// @param ethOutMin The minimum amount of WETH expected in return.
    /// @return amountOut The amount of WETH received from the swap.
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
