// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./BalancerTest.sol";

contract SetBalancerPoolId is BalancerTest {
    function test_defaultBehavior(bytes32 newPoolId) public {
        vm.assume(newPoolId != "");

        vm.prank(admin);
        balancer.setBalancerPoolId(newPoolId);

        assertEq(balancer.poolId(), newPoolId, "Pool id should have changed correctly");
    }

    function test_onlyOwner(bytes32 newPoolId) public {
        vm.expectRevert("Ownable: caller is not the owner");
        balancer.setBalancerPoolId(newPoolId);
    }
}
