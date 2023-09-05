// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./BalancerTest.sol";

contract SetBalancerVault is BalancerTest {
    function test_defaultBehavior(address newVault) public {
        vm.assume(newVault != address(0));

        vm.expectEmit();
        emit SetBalancerVault(newVault);

        vm.prank(admin);
        balancer.setBalancerVault(newVault);

        assertEq(balancer.vault(), newVault, "Vault should have changed correctly");
    }

    function test_onlyOwner(address newVault) public {
        vm.expectRevert("Ownable: caller is not the owner");
        balancer.setBalancerVault(newVault);
    }
}
