// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "test/MainnetTest.sol";
import {Uniswap} from "src/Uniswap.sol";

contract UniswapTest is MainnetTest {
    using SafeTransferLib for ERC20;

    UniswapMock uniswap;
    address admin;

    event SetUniswapRouter(address newRouter);

    function setUp() public virtual override {
        MainnetTest.setUp();
        admin = makeAddr("admin");
        vm.prank(admin);
        uniswap = new UniswapMock();
    }
}

contract UniswapMock is Uniswap {
    function etherize(address token, uint256 amountIn, uint256 ethOutMin, uint24 fee) external {
        _etherize(token, amountIn, ethOutMin, fee);
    }
}
