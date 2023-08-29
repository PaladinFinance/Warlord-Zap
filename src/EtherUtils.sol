// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

abstract contract EtherUtils {
    using SafeTransferLib for ERC20;

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function _resetWethAllowance(address target) internal {
        ERC20(WETH).safeApprove(target, type(uint256).max);
    }

    function _removeWethAllowance(address target) internal {
        ERC20(WETH).safeApprove(target, 0);
    }
}
