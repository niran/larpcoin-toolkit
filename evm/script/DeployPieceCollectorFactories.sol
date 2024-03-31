// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import "../src/subfactories/PieceCollectorFactory.sol";
import {GamePieceGovernorSimpleFactory} from "../src/subfactories/GamePieceGovernorSimpleFactory.sol";
import {TimelockControllerFactory} from "../src/subfactories/TimelockControllerFactory.sol";


contract DeployLarpcoinGameFactory is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        TimelockControllerFactory tcFactory = new TimelockControllerFactory();
        new GamePieceGovernorSimpleFactory(address(tcFactory));
        new PieceCollectorFactory();
        vm.stopBroadcast();
    }
}
