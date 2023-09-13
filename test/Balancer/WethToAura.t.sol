// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./BalancerTest.sol";
import {OneInchQuotes} from "../OneInchQuotes.sol";

contract WethToAura is BalancerTest, OneInchQuotes {
    using SafeTransferLib for ERC20;

    function setUp() public virtual override {
        blockNumber = 0;
        BalancerTest.setUp();

        vm.prank(admin);
        balancer.resetBalancerAllowance();
    }

    function assertSlippageLessThanOnePercent(uint256 amount, uint256 slippage_bps) public {
        deal(address(weth), address(balancer), amount);

        // Fetching the best price from 1inch API
        uint256 expectedAmount = fetchPrice(address(weth), address(aura), amount);
        // 1% slippage tollerated
        uint256 slippedExpectedAmount = expectedAmount * (10_000 - slippage_bps) / 10_000;
        balancer.wethToAura(amount, slippedExpectedAmount);
        uint256 swappedAmount = aura.balanceOf(address(balancer));

        assertApproxEqRel(swappedAmount, expectedAmount, 0.01e18, "Slippage should be smaller than 1%");
        console2.log(swappedAmount);
        console2.log(expectedAmount);
        assertEq(weth.balanceOf(address(balancer)), 0, "after swap no token should be left in contract balance");
    }

    function test_defaultBehavior() public {
        assertSlippageLessThanOnePercent(60 ether, 100);
    }
}
