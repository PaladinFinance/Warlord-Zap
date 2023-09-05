// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./CurveTest.sol";

contract ResetCurveAllowance is CurveTest {
    function test_defaultBehavior() public {
        vm.prank(admin);
        curve.resetCurveAllowance();
        assertEq(
            weth.allowance(address(curve), curve.wethCvxPool()),
            type(uint256).max,
            "Weth allowance for pool should be infinte"
        );
    }

    function test_onlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        curve.resetCurveAllowance();
    }
}
