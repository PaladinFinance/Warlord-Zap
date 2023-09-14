// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract ZapERC20ToMultipleTokens is ZapperTest {
    using SafeTransferLib for ERC20;

    function setUp() public override {
        ZapperTest.setUp();

        vm.startPrank(admin);
        zap.enableToken(address(usdc), 500);
        zap.enableToken(address(weth), 0);
        zap.resetBalancerAllowance();
        zap.resetCurveAllowance();
        zap.resetWarlordAllowances();
        vm.stopPrank();
    }

    function defaultBehavior(address token, uint256 amount, uint256 ratio) public {
        deal(token, alice, amount);

        vm.startPrank(alice);
        ERC20(token).safeApprove(address(zap), amount);

        zap.zapERC20ToMultipleTokens(token, amount, bob, ratio, 0, 0, 0);
        vm.stopPrank();

        assertEq(ERC20(token).balanceOf(alice), 0, "Alice shouldn't have any of the zap token left");

        assertGt(stkWar.balanceOf(bob), 0, "Bob should have received stkWar");
        assertEq(stkWar.balanceOf(alice), 0, "Alice shouldn't have received any stkWar");

        assertEq(weth.balanceOf(address(zap)), 0, "Zapper shouldn't have any weth left");

        assertEq(aura.balanceOf(address(zap)), 0, "Zapper shouldn't have any aura left");
        assertEq(cvx.balanceOf(address(zap)), 0, "Zapper shouldn't have any cvx left");
        assertEq(war.balanceOf(address(zap)), 0, "Zapper shouldn't have any unstaked war left");
    }

    function test_defaultBehaviorWeth(uint256 ratio) public {
        ratio = bound(ratio, 1, 9_999);
        defaultBehavior(address(weth), 10 ether, ratio);
    }

    function test_defaultBehaviorUsdc(uint256 ratio) public {
        ratio = bound(ratio, 1, 9_999);
        defaultBehavior(address(usdc), 20_000e6, ratio);
    }

    function test_tokenZeroAddress(uint256 amount, uint256 ratio) public {
        vm.assume(amount != 0);
        ratio = bound(ratio, 1, 9_999);

        vm.expectRevert(Errors.ZeroAddress.selector);

        zap.zapERC20ToMultipleTokens(address(0), amount, bob, ratio, 0, 0, 0);
    }

    function test_tokenNotAllowed(uint256 amount, uint256 ratio) public {
        vm.assume(amount != 0);
        ratio = bound(ratio, 1, 9_999);

        vm.startPrank(admin);
        zap.disableToken(address(usdc));
        zap.disableToken(address(weth));
        vm.stopPrank();

        vm.expectRevert(Errors.TokenNotAllowed.selector);
        zap.zapERC20ToMultipleTokens(address(usdc), amount, bob, ratio, 0, 0, 0);
        vm.expectRevert(Errors.TokenNotAllowed.selector);
        zap.zapERC20ToMultipleTokens(address(weth), amount, bob, ratio, 0, 0, 0);
    }

    function test_receiverZeroAddress(uint256 amount, uint256 ratio) public {
        vm.assume(amount != 0);
        ratio = bound(ratio, 1, 9_999);

        vm.expectRevert(Errors.ZeroAddress.selector);
        zap.zapERC20ToMultipleTokens(address(weth), amount, address(0), ratio, 0, 0, 0);
    }

    function test_nullAmount(uint256 ratio) public {
        ratio = bound(ratio, 1, 9_999);

        vm.expectRevert(Errors.NullAmount.selector);
        zap.zapERC20ToMultipleTokens(address(weth), 0, bob, ratio, 0, 0, 0);
    }

    function test_invalidRatio(uint256 invalidRatio, uint256 amount) public {
        vm.assume(amount != 0);
        vm.assume(invalidRatio == 0 || invalidRatio > 9_999);

        vm.expectRevert(Errors.InvalidRatio.selector);
        zap.zapERC20ToMultipleTokens(address(weth), amount, bob, invalidRatio, 0, 0, 0);
    }
}
