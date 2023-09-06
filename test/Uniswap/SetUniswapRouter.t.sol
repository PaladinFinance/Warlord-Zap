// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./UniswapTest.sol";

contract SetUniswapRouter is UniswapTest {
    function test_defaultBehavior(address newRouter) public {
        vm.assume(newRouter != address(0));

        vm.expectEmit();
        emit SetUniswapRouter(newRouter);

        vm.prank(admin);
        uniswap.setUniswapRouter(newRouter);

        assertEq(address(uniswap.swapRouter()), newRouter, "Router should have changed correctly");
    }

    function test_onlyOwner(address newRouter) public {
        vm.expectRevert("Ownable: caller is not the owner");
        uniswap.setUniswapRouter(newRouter);
    }

    function test_zeroAddress() public {
        vm.expectRevert(Errors.ZeroAddress.selector);

        vm.prank(admin);
        uniswap.setUniswapRouter(address(0));
    }
}
