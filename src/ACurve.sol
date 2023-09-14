// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Errors} from "src/Errors.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ICurvePool} from "curve/ICurvePool.sol";
import {EtherUtils} from "src/EtherUtils.sol";

/// @title ACurve
/// @author centonze.eth
/// @notice Utility functions related to Curve operations.
abstract contract ACurve is EtherUtils {
    using SafeTransferLib for ERC20;

    // Ethereum mainnet address of cvx.
    address internal constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    // Ethereum mainnet address of the WETH-CVX Curve pool.
    address public wethCvxPool = 0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4;

    /// @notice Emitted when the Curve pool address is updated.
    /// @param newPool The address of the new Curve pool.
    event SetCurvePool(address newPool);

    /// @notice Sets a new address for the Curve pool.
    /// @param _wethCvxPool The address of the new Curve pool.
    function setCurvePool(address _wethCvxPool) external onlyOwner {
        if (_wethCvxPool == address(0)) revert Errors.ZeroAddress();
        wethCvxPool = _wethCvxPool;

        emit SetCurvePool(_wethCvxPool);
    }

    /// @notice Resets WETH allowance for the specified Curve pool.
    function resetCurveAllowance() external onlyOwner {
        _resetWethAllowance(wethCvxPool);
    }

    /// @notice Removes WETH allowance for the specified Curve pool.
    function removeCurveAllowance() external onlyOwner {
        _removeWethAllowance(wethCvxPool);
    }

    /// @dev Converts a given amount of WETH into CVX using the specified Curve pool.
    /// @param amount The amount of WETH to be exchanged.
    /// @param cvxOutMin The minimum amount of CVX expected in return.
    function _wethToCvx(uint256 amount, uint256 cvxOutMin) internal {
        ICurvePool(wethCvxPool).exchange(0, 1, amount, cvxOutMin);
    }
}
