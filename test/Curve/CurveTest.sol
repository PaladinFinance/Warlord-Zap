// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "test/MainnetTest.sol";
import {Curve} from "src/Curve.sol";

contract CurveTest is MainnetTest {
    using SafeTransferLib for ERC20;

    CurveMock curve;
    address admin;

    event SetCurvePool(address newPool);

    function setUp() public override {
        MainnetTest.setUp();
        admin = makeAddr("admin");
        vm.prank(admin);
        curve = new CurveMock();
    }
}

contract CurveMock is Curve {
    function wethToCvx(uint256 amount, uint256 cvxOutMin) external {
        _wethToCvx(amount, cvxOutMin);
    }
}