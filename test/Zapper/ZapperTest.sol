// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "../MainnetTest.sol";
import {Zapper} from "src/Zapper.sol";

contract ZapperTest is MainnetTest {
    Zapper zap;
    address admin;

    event Zapped(address indexed token, uint256 amount, uint256 mintedAmount);
    event TokenUpdated(address indexed token, bool allowed, uint256 fee);
    event SetWarMinter(address newMinter);
    event SetWarStaker(address newStaker);

    function setUp() public virtual override {
        MainnetTest.setUp();

        admin = makeAddr("admin");
        vm.prank(admin);
        zap = new Zapper();
    }
}
