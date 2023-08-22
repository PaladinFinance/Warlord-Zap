// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {IWarToken} from "warlord/IWarToken.sol";
import {IWarStaker} from "warlord/IWarStaker.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract MainnetTest is Test {
    using SafeTransferLib for ERC20;

    ERC20 public constant war = ERC20(0xa8258deE2a677874a48F5320670A869D74f0cbC1);
    IWarStaker public constant stkWar = IWarStaker(0xA86c53AF3aadF20bE5d7a8136ACfdbC4B074758A);
    ERC20 public constant weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
      vm.label(address(war), "WAR");
      vm.label(address(stkWar), "stkWAR");
      vm.label(address(weth), "WETH");

      // WarZap zap = 0xf747744518099F44936D6D58041De6cD199C35aF;
      // WarMinter minter = 0x144a689A8261F1863c89954930ecae46Bd950341;
    }
}
