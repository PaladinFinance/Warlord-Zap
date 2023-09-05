// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "test/MainnetTest.sol";
import {Balancer} from "src/Balancer.sol";

contract BalancerTest is MainnetTest {
    using SafeTransferLib for ERC20;

    BalancerMock balancer;
    address admin;

    function setUp() public override {
        MainnetTest.setUp();
        admin = makeAddr("admin");
        vm.prank(admin);
        balancer = new BalancerMock();
    }
}

contract BalancerMock is Balancer {
    function wethToAura(uint256 amount, uint256 auraOutMin) external {
        _wethToAura(amount, auraOutMin);
    }
}
