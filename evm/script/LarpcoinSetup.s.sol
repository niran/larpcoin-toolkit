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
            liquiditySupply: 500_000_000e18,
            // Prices when larpcoin market cap is 10 ETH
            larpcoinSqrtPriceX96: 7922816251426434139029504,
            wethSqrtPriceX96: 792281625142643375935439503360000,
            remainderRecipient: address(this)
        });
        GamePieceArgs memory gpArgs = GamePieceArgs({
            name: "GamePiece",
            symbol: "LGP",
            cost: 0.001e18,
            roundLength: 30 * 86400,
            tokenURI: "http://example.com"
        });

        vm.startBroadcast();
        LarpcoinFactory factory = new LarpcoinFactory(
            0x1238536071E1c677A632429e3655c799b22cDA52,
            0x0227628f3F023bb0B980b67D528571c95c6DaC1c,
            0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14
        );
        factory.build(lcArgs, gpArgs, 86400 /* 1 day */);
        vm.stopBroadcast();
    }
}
