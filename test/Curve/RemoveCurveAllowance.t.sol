// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./CurveTest.sol";

contract RemoveCurveAllowance is CurveTest {
    function test_defaultBehavior() public {
        vm.prank(admin);
        curve.removeCurveAllowance();
        assertEq(weth.allowance(address(curve), curve.wethCvxPool()), 0, "Weth allowance for pool should be zero");
    }

    function test_onlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        curve.removeCurveAllowance();
    }
}
