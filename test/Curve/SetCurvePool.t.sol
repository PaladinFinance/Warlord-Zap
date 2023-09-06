// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./CurveTest.sol";

contract SetCurvePool is CurveTest {
    function test_defaultBehavior(address newPool) public {
        vm.assume(newPool != address(0));

        vm.expectEmit();
        emit SetCurvePool(newPool);

        vm.prank(admin);
        curve.setCurvePool(newPool);

        assertEq(curve.wethCvxPool(), newPool, "Pool should have changed correctly");
    }

    function test_onlyOwner(address newPool) public {
        vm.expectRevert("Ownable: caller is not the owner");
        curve.setCurvePool(newPool);
    }

    function test_zeroAddress() public {
        vm.expectRevert(Errors.ZeroAddress.selector);

        vm.prank(admin);
        curve.setCurvePool(address(0));
    }
}
