// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./UniswapTest.sol";

contract Etherize is UniswapTest {
    function setUp() public override {
        blockNumber = 0;
        UniswapTest.setUp();
    }

    function test_wip() public {
        console2.log(block.number);
    }
}
