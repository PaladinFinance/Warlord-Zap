// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract ZapERC20ToSingleToken is ZapperTest {
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

    function defaultBehavior(address token, uint256 amount, bool useCvx) public {
        deal(token, alice, amount);

        vm.startPrank(alice);
        ERC20(token).safeApprove(address(zap), amount);

        zap.zapERC20ToSingleToken(token, amount, bob, useCvx, 0, 0);
        vm.stopPrank();

        assertEq(ERC20(token).balanceOf(alice), 0, "Alice shouldn't have any of the zap token left");

        assertGt(stkWar.balanceOf(bob), 0, "Bob should have received stkWar");
        assertEq(stkWar.balanceOf(alice), 0, "Alice shouldn't have received any stkWar");

        assertEq(weth.balanceOf(address(zap)), 0, "Zapper shouldn't have any weth left");

        assertEq(aura.balanceOf(address(zap)), 0, "Zapper shouldn't have any aura left");
        assertEq(cvx.balanceOf(address(zap)), 0, "Zapper shouldn't have any cvx left");
        assertEq(war.balanceOf(address(zap)), 0, "Zapper shouldn't have any unstaked war left");
    }

    function test_defaultBehaviorWeth() public {
        defaultBehavior(address(weth), 10 ether, false);
        defaultBehavior(address(weth), 10 ether, true);
    }

    function test_defaultBehaviorUsdc() public {
        defaultBehavior(address(usdc), 20_000e6, false);
        defaultBehavior(address(usdc), 20_000e6, true);
    }

    function test_tokenZeroAddress(uint256 amount, bool useCvx) public {
        vm.expectRevert(Errors.ZeroAddress.selector);

        zap.zapERC20ToSingleToken(address(0), amount, bob, useCvx, 0, 0);
    }

    function test_tokenNotAllowed(uint256 amount, bool useCvx) public {
        vm.startPrank(admin);
        zap.disableToken(address(usdc));
        zap.disableToken(address(weth));
        vm.stopPrank();

        vm.expectRevert(Errors.TokenNotAllowed.selector);
        zap.zapERC20ToSingleToken(address(usdc), amount, bob, useCvx, 0, 0);
        vm.expectRevert(Errors.TokenNotAllowed.selector);
        zap.zapERC20ToSingleToken(address(weth), amount, bob, useCvx, 0, 0);
    }

    function test_receiverZeroAddress(uint256 amount, bool useCvx) public {
        vm.expectRevert(Errors.ZeroAddress.selector);
        zap.zapERC20ToSingleToken(address(weth), amount, address(0), useCvx, 0, 0);
    }

    function test_nullAmount(bool useCvx) public {
        vm.expectRevert(Errors.NullAmount.selector);
        zap.zapERC20ToSingleToken(address(weth), 0, bob, useCvx, 0, 0);
    }
}
