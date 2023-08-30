// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./MainnetTest.sol";
import {Zapper} from "src/Zapper.sol";

contract E2E is MainnetTest {
    Zapper zapper;
    address alice;
    address admin;

    function setUp() public override {
        MainnetTest.setUp();

        alice = makeAddr("alice");
        admin = makeAddr("admin");

        vm.prank(admin);
        zapper = new Zapper();

        vm.startPrank(admin);
        zapper.enableToken(address(usdc), 500);
        zapper.resetBalancerAllowance();
        zapper.resetWarlordAllowances();
        zapper.resetCurveAllowance();
        vm.stopPrank();

        vm.prank(alice);
        usdc.approve(address(zapper), type(uint256).max);

        deal(address(usdc), alice, 10_000e6);
    }

    function test_completeZapOnlyAura() public {
        vm.prank(alice);
        zapper.zapSingleToken(address(usdc), 1000e6, alice, false, 0, 0);
    }

    function test_completeZapOnlyCvx() public {
        vm.prank(alice);
        zapper.zapSingleToken(address(usdc), 1000e6, alice, true, 0, 0);
    }

    function test_compeleteZapBoth() public {
        vm.prank(alice);
        zapper.zapMultipleTokens(address(usdc), 1000e6, alice, 5000, 0, 0, 0);
    }
}
