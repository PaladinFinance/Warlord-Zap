// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract DisableToken is ZapperTest {
    address enabledToken;

    function setUp() public override {
        ZapperTest.setUp();

        enabledToken = address(new MockERC20());

        vm.prank(admin);
        zap.enableToken(enabledToken, 500);
    }

    function test_defaultBehavior() public {
        vm.expectEmit();
        emit TokenUpdated(enabledToken, false, 500);

        vm.prank(admin);
        zap.disableToken(enabledToken);

        assertFalse(zap.allowedTokens(enabledToken), "Token should be enabled");
        assertEq(ERC20(enabledToken).allowance(address(zap), address(uniRouter)), 0, "Allowance should be maxed");
    }

    function test_onlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        zap.disableToken(enabledToken);
    }

    function test_zeroAddress() public {
        vm.expectRevert(Errors.ZeroAddress.selector);

        vm.prank(admin);
        zap.disableToken(address(0));
    }
}
