// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Errors} from "src/Errors.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {IVault} from "balancer/IVault.sol";
import {EtherUtils} from "src/EtherUtils.sol";

abstract contract ABalancer is EtherUtils {
    using SafeTransferLib for ERC20;

    // Ethereum mainnet address of cvx.
    address internal constant AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;

    // Ethereum mainnet address balanlcer vault.
    address public vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    // Ethereum mainnet id for balancer AURA-WETH pool.
    bytes32 public poolId = 0xcfca23ca9ca720b6e98e3eb9b6aa0ffc4a5c08b9000200000000000000000274;

    /// @notice Emitted when the Balancer vault address is updated.
    /// @param newVault The address of the new Balancer vault.
    event SetBalancerVault(address newVault);

    /// @notice Emitted when the Balancer pool ID is updated.
    /// @param newPoolId The new pool ID.
    event SetBalancerPoolId(bytes32 newPoolId);

    /// @notice Sets a new address for the Balancer vault.
    /// @param _vault The address of the new Balancer vault.
    function setBalancerVault(address _vault) external onlyOwner {
        if (_vault == address(0)) revert Errors.ZeroAddress();
        vault = _vault;

        emit SetBalancerVault(_vault);
    }

    /// @notice Sets a new pool ID for Balancer operations.
    /// @param _poolId The new pool ID.
    function setBalancerPoolId(bytes32 _poolId) external onlyOwner {
        poolId = _poolId;

        emit SetBalancerPoolId(_poolId);
    }

    /// @notice Resets WETH allowance for the specified Balancer vault.
    function resetBalancerAllowance() external onlyOwner {
        _resetWethAllowance(vault);
    }

    /// @notice Removes WETH allowance for the specified Balancer vault.
    function removeBalancerAllowance() external onlyOwner {
        _removeWethAllowance(vault);
    }

    /// @dev Converts a given amount of WETH into AURA using the specified Balancer pool.
    /// @param amount The amount of WETH to be exchanged.
    /// @param auraOutMin The minimum amount of AURA expected in return.
    function _wethToAura(uint256 amount, uint256 auraOutMin) internal {
        IVault.SingleSwap memory params = IVault.SingleSwap({
            poolId: poolId,
            kind: 0, // exact input, output given
            assetIn: WETH,
            assetOut: AURA,
            amount: amount, // Amount to swap
            userData: ""
        });

        IVault.FundManagement memory funds = IVault.FundManagement({
            sender: address(this), // Funds are taken from this contract
            recipient: address(this), // Swapped tokens are sent back to this contract
            fromInternalBalance: false, // Don't take funds from contract LPs (since there's none)
            toInternalBalance: false // Don't LP with swapped funds
        });

        IVault(vault).swap(params, funds, auraOutMin, block.timestamp);
    }
}
