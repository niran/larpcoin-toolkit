// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";

import "../src/LarpcoinGameFactory.sol";
import {LarpcoinFactory} from "../src/subfactories/LarpcoinFactory.sol";
import {LarpcoinGovernorFactory} from "../src/subfactories/LarpcoinGovernorFactory.sol";
import {GamePieceFactory} from "../src/subfactories/GamePieceFactory.sol";
import {GamePieceGovernorFactory} from "../src/subfactories/GamePieceGovernorFactory.sol";
import {TimelockControllerFactory} from "../src/subfactories/TimelockControllerFactory.sol";
import {SlowlockFactory} from "../src/subfactories/SlowlockFactory.sol";


contract DeployLarpcoinGameFactory is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        LarpcoinFactory lcFactory = new LarpcoinFactory(
            // Sepolia addresses. Replace when deploying on other chains.
            0x1238536071E1c677A632429e3655c799b22cDA52, // Uniswap NonfungiblePositionManager
            0x0227628f3F023bb0B980b67D528571c95c6DaC1c, // UniswapV3Factory
            0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14  // WETH9
        );
        TimelockControllerFactory tcFactory = new TimelockControllerFactory();
        SlowlockFactory slowlockFactory = new SlowlockFactory();
        GamePieceFactory gpFactory = new GamePieceFactory();
        LarpcoinGovernorFactory lcGovFactory = new LarpcoinGovernorFactory(address(tcFactory));
        GamePieceGovernorFactory gpGovFactory = new GamePieceGovernorFactory(address(tcFactory), address(slowlockFactory), address(gpFactory));
        new LarpcoinGameFactory(address(lcFactory), address(lcGovFactory), address(gpGovFactory));
        vm.stopBroadcast();
    }
}
