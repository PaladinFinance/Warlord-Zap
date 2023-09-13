// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "../MainnetTest.sol";
import {Zapper} from "src/Zapper.sol";

contract ZapperTest is MainnetTest {
    Zapper zap;
    address admin;

    address alice;
    address bob;

    event Zapped(address indexed token, uint256 amount, uint256 mintedAmount);
    event TokenUpdated(address indexed token, bool allowed);
    event SetWarMinter(address newMinter);
    event SetWarStaker(address newStaker);
    event SetUniswapFee(address indexed token, uint24 fee);

    function setUp() public virtual override {
        MainnetTest.setUp();

        admin = makeAddr("admin");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        vm.prank(admin);
        zap = new Zapper();
    }
}
