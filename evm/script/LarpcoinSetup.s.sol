// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";

import "../src/LarpcoinFactory.sol";
import {GamePiece} from "../src/GamePiece.sol";
import {LarpcoinGovernor} from "../src/LarpcoinGovernor.sol";
import {GamePieceGovernor} from "../src/GamePieceGovernor.sol";


contract LarpcoinSetup is Script {
    function setUp() public {}

    function run() public {
        LarpcoinArgs memory lcArgs = LarpcoinArgs({
            name: "Larpcoin",
            symbol: "LARP",
            totalSupply: 1_000_000_000e18,
            supplyOwner: address(this)
        });
        GamePieceArgs memory gpArgs = GamePieceArgs({
            name: "GamePiece",
            symbol: "LGP",
            cost: 0.001e18,
            roundLength: 30 * 86400,
            tokenURI: "http://example.com"
        });

        vm.startBroadcast();
        LarpcoinFactory factory = new LarpcoinFactory();
        factory.build(lcArgs, gpArgs, 86400 /* 1 day */);
        vm.stopBroadcast();
    }
}
