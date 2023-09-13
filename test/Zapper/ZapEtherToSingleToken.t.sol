// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract ZapEtherToSingleToken is ZapperTest {
  function setUp() public override {
    ZapperTest.setUp();

    vm.startPrank(admin);
    zap.resetBalancerAllowance();
    zap.resetWarlordAllowances();
    vm.stopPrank();

    vm.deal(alice, 1 ether);
  }

  function defaultBehavior(bool useCvx) public {
    vm.prank(alice);
    zap.zapEtherToSingleToken{value: 1 ether}(bob, useCvx, 0);
    assertGt(stkWar.balanceOf(bob), 0, "Bob should have received stkWar");

    assertEq(alice.balance, 0, "Alice shouldn't have any eth left");
    assertEq(weth.balanceOf(alice), 0, "Alice shouldn't have any weth left");

    assertEq(address(zap).balance, 0, "Zapper shouldn't have any eth left");
    assertEq(weth.balanceOf(address(zap)), 0, "Zapper shouldn't have any weth left");

    assertEq(aura.balanceOf(address(zap)), 0, "Zapper shouldn't have any aura left");
    assertEq(cvx.balanceOf(address(zap)), 0, "Zapper shouldn't have any cvx left");
    assertEq(war.balanceOf(address(zap)), 0, "Zapper shouldn't have any unstaked war left");
  }

  function test_defaultBehaviorAura() public {
    defaultBehavior(false);
  }

  function test_defaultBehaviorCvx() public {
    defaultBehavior(true);
  }

  function test_zeroAddressAura() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    zap.zapEtherToSingleToken{value: 1 ether}(address(0), false, 0);
  }
  function test_zeroAddressCvx() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    zap.zapEtherToSingleToken{value: 1 ether}(address(0), true, 0);
  }

  function test_nullAmountAura() public {
    vm.expectRevert(Errors.NullAmount.selector);
    zap.zapEtherToSingleToken(bob, false, 0);
  }
  function test_nullAmountCvx() public {
    vm.expectRevert(Errors.NullAmount.selector);
    zap.zapEtherToSingleToken(bob, true, 0);
  }
}
