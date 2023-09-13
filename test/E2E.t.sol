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

    function test_zapOnlyAura() public {
        vm.prank(alice);
        zapper.zapERC20ToSingleToken(address(usdc), 1000e6, alice, false, 0, 0);
    }

    function test_zapOnlyCvx() public {
        vm.prank(alice);
        zapper.zapERC20ToSingleToken(address(usdc), 1000e6, alice, true, 0, 0);
    }

    function test_zapBoth() public {
        vm.prank(alice);
        zapper.zapERC20ToMultipleTokens(address(usdc), 1000e6, alice, 5000, 0, 0, 0);
    }

    function test_zapOnlyAuraNativeEth() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        zapper.zapEtherToSingleToken{value: 1 ether}(alice, false, 0);
    }

    function test_zapOnlyCvxNativeEth() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        zapper.zapEtherToSingleToken{value: 1 ether}(alice, true, 0);
    }

    function test_zapBothNativeEth() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        zapper.zapEtherToMultipleTokens{value: 1 ether}(alice, 5000, 0, 0);
    }

    // function test_zapFromEther() public {
    // uint256 etherAmount = 50 ether;

    // deal(address(weth), address(zapper), etherAmount);
    // zapper.zapSingleToken(address(weth));
    // }
}
