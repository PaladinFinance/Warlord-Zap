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
        zapper.zapThroughSingleToken(address(usdc), 1000e6, alice, false);
    }

    function test_completeZapOnlyCvx() public {
        vm.prank(alice);
        zapper.zapThroughSingleToken(address(usdc), 1000e6, alice, true);
    }

    function test_compeleteZapBoth() public {
        vm.prank(alice);
        zapper.zapThroughMultipleTokens(address(usdc), 1000e6, alice, 5000);
    }
}
