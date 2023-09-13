// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./UniswapTest.sol";
import {OneInchQuotes} from "../OneInchQuotes.sol";

contract Etherize is UniswapTest, OneInchQuotes {
    using SafeTransferLib for ERC20;

    function setUp() public virtual override {
        blockNumber = 0;
        UniswapTest.setUp();
    }

    function assertSlippageLessThanOnePercent(address token, uint24 fee, uint256 amount, uint256 slippage_bps) public {
        uniswap.resetUniswapAllowance(token);

        deal(token, address(uniswap), amount);

        // Fetching the best price from 1inch API
        uint256 expectedAmount = fetchPrice(address(token), address(weth), amount);
        // 1% slippage tollerated
        uint256 slippedExpectedAmount = expectedAmount * (10_000 - slippage_bps) / 10_000;
        uniswap.etherize(token, amount, slippedExpectedAmount, fee);
        uint256 swappedAmount = weth.balanceOf(address(uniswap));

        assertApproxEqRel(swappedAmount, expectedAmount, 0.01e18, "Slippage should be smaller than 1%");
        assertEq(ERC20(token).balanceOf(address(uniswap)), 0, "after swap no token should be left in contract balance");
    }

    function test_stablecoinToEtherSlippage() public {
        uint256 snapshot = vm.snapshot();
        assertSlippageLessThanOnePercent(address(dai), 3000, 1_000_000e6, 100);
        // Swap up to 1 milion usdc with a 0.05 fee
        vm.revertTo(snapshot);
        assertSlippageLessThanOnePercent(address(usdc), 500, 1_000_000e6, 100);
        // Swap up to 1 milion usdt with a 0.05 fee
        vm.revertTo(snapshot);
        // Swap up to 1 milion dai with a 0.3 fee
        assertSlippageLessThanOnePercent(address(usdt), 500, 1_000_000e6, 100);
    }
}
