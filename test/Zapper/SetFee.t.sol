// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract SetFee is ZapperTest {
    address enabledToken;

    function setUp() public override {
        ZapperTest.setUp();

        enabledToken = address(new MockERC20());

        vm.prank(admin);
        zap.enableToken(enabledToken, 500);
    }

    function test_defaultBehavior(uint24 fee) public {
        vm.expectEmit();
        emit TokenUpdated(enabledToken, true, fee);

        vm.prank(admin);
        zap.setFee(enabledToken, fee);

        assertEqDecimal(zap.fees(enabledToken), fee, 2, "Fee should be set correctly");
    }

    function test_onlyOwner(uint24 fee) public {
        vm.expectRevert("Ownable: caller is not the owner");
        zap.setFee(enabledToken, fee);
    }

    function test_ZeroAddress(uint24 fee) public {
        vm.expectRevert(Errors.ZeroAddress.selector);

        vm.prank(admin);
        zap.setFee(address(0), fee);
    }

    function test_TokenNotAllowed(uint24 fee) public {
        address notAllowedMock = address(new MockERC20());

        vm.expectRevert(Errors.TokenNotAllowed.selector);

        vm.prank(admin);
        zap.setFee(notAllowedMock, fee);
    }
}
