// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./BalancerTest.sol";

contract RemoveBalancerAllowance is BalancerTest {
    function test_defaultBehavior() public {
        vm.prank(admin);
        balancer.removeBalancerAllowance();
        assertEq(weth.allowance(address(balancer), balancer.vault()), 0, "Weth allowance for vault should be zero");
    }

    function test_onlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        balancer.removeBalancerAllowance();
    }
}
