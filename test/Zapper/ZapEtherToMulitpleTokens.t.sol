// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract ZapEtherToMultipleTokens is ZapperTest {
    function setUp() public override {
        ZapperTest.setUp();

        vm.startPrank(admin);
        zap.resetBalancerAllowance();
        zap.resetCurveAllowance();
        zap.resetWarlordAllowances();
        vm.stopPrank();

        vm.deal(alice, 1 ether);
    }

    function defaultBehavior(uint256 ratio) public {}

    function test_defaultBehavior(uint256 ratio) public {
        ratio = bound(ratio, 1, 9_999);
        vm.deal(alice, 1 ether);

        vm.prank(alice);
        zap.zapEtherToMultipleTokens{value: 1 ether}(bob, ratio, 0, 0);

        assertGt(stkWar.balanceOf(bob), 0, "Bob should have received stkWar");
        assertEq(stkWar.balanceOf(alice), 0, "Alice shouldn't have received any stkWar");

        assertEq(alice.balance, 0, "Alice shouldn't have any eth left");
        assertEq(weth.balanceOf(alice), 0, "Alice shouldn't have any weth left");

        assertEq(address(zap).balance, 0, "Zapper shouldn't have any eth left");
        assertEq(weth.balanceOf(address(zap)), 0, "Zapper shouldn't have any weth left");

        assertEq(aura.balanceOf(address(zap)), 0, "Zapper shouldn't have any aura left");
        assertEq(cvx.balanceOf(address(zap)), 0, "Zapper shouldn't have any cvx left");
        assertEq(war.balanceOf(address(zap)), 0, "Zapper shouldn't have any unstaked war left");
    }

    function test_zeroAddress(uint256 ratio) public {
        ratio = bound(ratio, 1, 9_999);

        vm.expectRevert(Errors.ZeroAddress.selector);
        zap.zapEtherToMultipleTokens{value: 1 ether}(address(0), ratio, 0, 0);
    }

    function test_nullAmountAura(uint256 ratio) public {
        ratio = bound(ratio, 1, 9_999);

        vm.expectRevert(Errors.NullAmount.selector);
        zap.zapEtherToMultipleTokens(bob, ratio, 0, 0);
    }

    function test_invalidRatio(uint256 invalidRatio) public {
        vm.assume(invalidRatio == 0 || invalidRatio > 9_999);

        vm.expectRevert(Errors.InvalidRatio.selector);
        zap.zapEtherToMultipleTokens{value: 1 ether}(bob, invalidRatio, 0, 0);
    }
}
