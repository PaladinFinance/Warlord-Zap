// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract RemoveWarlordAllowance is ZapperTest {
    function setUp() public override {
        ZapperTest.setUp();

        vm.prank(admin);
        zap.resetWarlordAllowances();
    }

    function test_defaultBehavior() public {
        vm.prank(admin);
        zap.removeWarlordAllowances();

        assertEq(aura.allowance(address(zap), zap.warMinter()), 0, "Aura allowance for minter should be zero");
        assertEq(cvx.allowance(address(zap), zap.warMinter()), 0, "Cvx allowance for minter should be zero");
        assertEq(war.allowance(address(zap), zap.warStaker()), 0, "War allowance for staker should be zero");
    }

    function test_onlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        zap.removeWarlordAllowances();
    }
}
