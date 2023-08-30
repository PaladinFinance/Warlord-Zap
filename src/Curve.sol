// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Errors} from "src/Errors.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ICurvePool} from "curve/ICurvePool.sol";
import {EtherUtils} from "src/EtherUtils.sol";

abstract contract Curve is EtherUtils {
    using SafeTransferLib for ERC20;

    address public CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    address private wethCvxPool = 0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4;

    function setCurvePool(address _wethCvxPool) external onlyOwner {
        if (_wethCvxPool == address(0)) revert Errors.ZeroAddress();
        wethCvxPool = _wethCvxPool;
    }

    function resetCurveAllowance() external onlyOwner {
        _resetWethAllowance(wethCvxPool);
    }

    function removeCurveAllowance() external onlyOwner {
        _removeWethAllowance(wethCvxPool);
    }

    function _wethToCvx(uint256 amount, uint256 cvxOutMin) internal {
        ERC20(WETH).safeApprove(wethCvxPool, amount);
        ICurvePool(wethCvxPool).exchange(0, 1, amount, cvxOutMin);
    }
}
