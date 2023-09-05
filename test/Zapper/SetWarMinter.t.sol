// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract SetWarMinter is ZapperTest {
    function test_defaultBehavior(address newWarMinter) public {
        vm.assume(newWarMinter != address(0));

        vm.expectEmit();
        emit SetWarMinter(newWarMinter);

        vm.prank(admin);
        zap.setWarMinter(newWarMinter);

        assertEq(zap.warMinter(), newWarMinter, "war minter should have been changed");
    }

    function test_onlyOnwer(address newWarMinter) public {
        vm.expectRevert("Ownable: caller is not the owner");
        zap.setWarMinter(newWarMinter);
    }

    function test_zeroAddress() public {
        vm.expectRevert(Errors.ZeroAddress.selector);

        vm.prank(admin);
        zap.setWarMinter(address(0));
    }
}
