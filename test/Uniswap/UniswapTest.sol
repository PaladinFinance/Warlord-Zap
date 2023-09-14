// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "test/MainnetTest.sol";
import {AUniswap} from "src/AUniswap.sol";

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

contract UniswapMock is AUniswap {
    using SafeTransferLib for ERC20;

    function setUniswapFee(address token, uint24 fee) external {
        _setUniswapFee(token, fee);
    }

    function etherize(address token, uint256 amountIn, uint256 ethOutMin) external {
        _etherize(token, amountIn, ethOutMin);
    }

    function resetUniswapAllowance(address token) external {
        ERC20(token).safeApprove(address(swapRouter), type(uint256).max);
    }
}
