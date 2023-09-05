// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./BalancerTest.sol";

contract ResetBalancerAllowance is BalancerTest {
    function test_defaultBehavior() public {
        vm.prank(admin);
        balancer.resetBalancerAllowance();
        assertEq(
            weth.allowance(address(balancer), balancer.vault()),
            type(uint256).max,
            "Weth allowance for vault should be infinte"
        );
    }

    function test_onlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        balancer.resetBalancerAllowance();
    }
}
