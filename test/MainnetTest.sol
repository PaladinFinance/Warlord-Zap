// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {IWarStaker} from "warlord/IWarStaker.sol";
import {ISwapRouter} from "uniswap/ISwapRouter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {Balancer} from "src/Balancer.sol";
// import {Curve} from "src/Curve.sol";
// import {Uniswap} from "src/Uniswap.sol";

contract MainnetTest is Test {
    using SafeTransferLib for ERC20;

    ERC20 public constant war = ERC20(0xa8258deE2a677874a48F5320670A869D74f0cbC1);
    ERC20 public constant weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 public constant usdc = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20 public constant cvx = ERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    ERC20 public constant aura = ERC20(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
    IWarStaker public constant stkWar = IWarStaker(0xA86c53AF3aadF20bE5d7a8136ACfdbC4B074758A);
    ISwapRouter public constant uniRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    function fork() public returns (uint256) {
        return vm.createSelectFork(vm.rpcUrl("ethereum"), 18026454);
    }

    function setUp() public virtual {
        fork();

        vm.label(address(war), "WAR");
        vm.label(address(stkWar), "stkWAR");
        vm.label(address(weth), "WETH");
        vm.label(address(uniRouter), "Uniswap Router");
        vm.label(address(usdc), "USDC");
        vm.label(address(cvx), "CVX");
        vm.label(address(aura), "AURA");

        // WarZap zap = 0xf747744518099F44936D6D58041De6cD199C35aF;
        // WarMinter minter = 0x144a689A8261F1863c89954930ecae46Bd950341;
    }
}

contract BalancerMock is Balancer {
    function wethToAura(uint256 amount, uint256 auraOutMin) external {
        _wethToAura(amount, auraOutMin);
    }
}
// contract UniswapMock is Uniswap {}
// contract CurveMock is Curve {}
