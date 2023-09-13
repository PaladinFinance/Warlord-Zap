// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./CurveTest.sol";
import {OneInchQuotes} from "../OneInchQuotes.sol";

contract WethToCvx is CurveTest, OneInchQuotes {
    using SafeTransferLib for ERC20;

    function setUp() public virtual override {
        blockNumber = 0;
        CurveTest.setUp();

        vm.prank(admin);
        curve.resetCurveAllowance();
    }

    function assertSlippageLessThanOnePercent(uint256 amount, uint256 slippage_bps) public {
        deal(address(weth), address(curve), amount);

        // Fetching the best price from 1inch API
        uint256 expectedAmount = fetchPrice(address(weth), address(cvx), amount);
        // 1% slippage tollerated
        uint256 slippedExpectedAmount = expectedAmount * (10_000 - slippage_bps) / 10_000;
        curve.wethToCvx(amount, slippedExpectedAmount);
        uint256 swappedAmount = cvx.balanceOf(address(curve));

        assertApproxEqRel(swappedAmount, expectedAmount, 0.01e18, "Slippage should be smaller than 1%");
        assertEq(weth.balanceOf(address(curve)), 0, "after swap no token should be left in contract balance");
    }

    function test_defaultBehavior() public {
        assertSlippageLessThanOnePercent(600 ether, 100);
    }
}
