// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {IWarStaker} from "warlord/IWarStaker.sol";
import {ISwapRouter} from "uniswap/ISwapRouter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract MainnetTest is Test {
    using SafeTransferLib for ERC20;

    ERC20 public constant war = ERC20(0xa8258deE2a677874a48F5320670A869D74f0cbC1);
    ERC20 public constant weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 public constant usdc = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IWarStaker public constant stkWar = IWarStaker(0xA86c53AF3aadF20bE5d7a8136ACfdbC4B074758A);
    ISwapRouter public constant uniRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    function fork() public returns (uint256) {
      return vm.createSelectFork(vm.rpcUrl("ethereum"), 17971002);
    }

    function setUp() virtual public {
      fork();

      vm.label(address(war), "WAR");
      vm.label(address(stkWar), "stkWAR");
      vm.label(address(weth), "WETH");
      vm.label(address(uniRouter), "Uniswap Router");
      vm.label(address(usdc), "USDC");

      // WarZap zap = 0xf747744518099F44936D6D58041De6cD199C35aF;
      // WarMinter minter = 0x144a689A8261F1863c89954930ecae46Bd950341;
    }
}
