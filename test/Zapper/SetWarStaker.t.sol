// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract SetWarStaker is ZapperTest {
    function test_defaultBehavior(address newWarStaker) public {
        vm.assume(newWarStaker != address(0));

        vm.expectEmit();
        emit SetWarStaker(newWarStaker);

        vm.prank(admin);
        zap.setWarStaker(newWarStaker);

        assertEq(zap.warStaker(), newWarStaker, "war staker should have been changed");
    }

    function test_onlyOnwer(address newWarStaker) public {
        vm.expectRevert("Ownable: caller is not the owner");
        zap.setWarStaker(newWarStaker);
    }

    function test_zeroAddress() public {
        vm.expectRevert(Errors.ZeroAddress.selector);

        vm.prank(admin);
        zap.setWarStaker(address(0));
    }
}
