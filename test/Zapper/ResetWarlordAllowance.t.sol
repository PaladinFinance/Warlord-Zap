// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ZapperTest.sol";

contract ResetWarlordAllowance is ZapperTest {
    function test_defaultBehavior() public {
        vm.prank(admin);
        zap.resetWarlordAllowances();

        assertEq(
            aura.allowance(address(zap), zap.warMinter()),
            type(uint256).max,
            "Aura allowance for minter should be maxed"
        );
        assertEq(
            cvx.allowance(address(zap), zap.warMinter()), type(uint256).max, "Cvx allowance for minter should be maxed"
        );
        assertEq(
            war.allowance(address(zap), zap.warStaker()), type(uint256).max, "War allowance for staker should be maxed"
        );
    }

    function test_onlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        zap.resetWarlordAllowances();
    }
}
