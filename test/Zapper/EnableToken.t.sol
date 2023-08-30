// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract EnableToken is ZapperTest {
    address mock;

    function setUp() public override {
        ZapperTest.setUp();

        mock = address(new MockERC20());
    }

    function test_defaultBehavior(uint24 fee) public {
        vm.expectEmit();
        emit TokenUpdated(mock, true, fee);

        vm.prank(admin);
        zap.enableToken(mock, fee);

        assertTrue(zap.allowedTokens(mock), "Token should be enabled");
        assertEqDecimal(zap.fees(mock), fee, 2, "Fee should be set correctly");
        assertEq(
            ERC20(mock).allowance(address(zap), address(uniRouter)), type(uint256).max, "Allowance should be maxed"
        );
    }

    function test_onlyOwner(address token, uint24 fee) public {
        vm.assume(token != address(0));

        vm.expectRevert("Ownable: caller is not the owner");
        zap.enableToken(token, fee);
    }

    function test_zeroAddress(uint24 fee) public {
        vm.expectRevert(Errors.ZeroAddress.selector);

        vm.prank(admin);
        zap.enableToken(address(0), fee);
    }

    function test_tokenAlreadyAllowed(uint24 fee, uint24 otherFee) public {
        vm.prank(admin);
        zap.enableToken(mock, fee);

        vm.expectRevert(Errors.TokenAlreadyAllowed.selector);
        vm.prank(admin);
        zap.enableToken(mock, otherFee);
    }
}
