// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import "../src/subfactories/PieceCollectorFactory.sol";
import {GamePieceGovernorSimpleFactory} from "../src/subfactories/GamePieceGovernorSimpleFactory.sol";
import {TimelockControllerFactory} from "../src/subfactories/TimelockControllerFactory.sol";
import {GovernanceArgs} from "../src/subfactories/GovernanceArgs.sol";


contract DeployAllFactories is Script {
    function setUp() public {}

    function run() public {
        ValuablePiece[] memory pieces = new ValuablePiece[](1);
        pieces[0] = ValuablePiece({
            nft: 0x5Cebe30d5467a3F8982bE27D413eA56Cd8681E2d,
            erc1155TokenId: 1,
            value: 52_725e18 / 1e3,
            mintUrl: "https://zora.co/collect/base:0x5cebe30d5467a3f8982be27d413ea56cd8681e2d/1",
            forceERC1155: true
        });

        PieceCollectorArgs memory pcArgs = PieceCollectorArgs({
            name: "higher collectors society",
            symbol: "HIGHERCS",
            cost: 4444e18 / 1e2,
            roundLength: 7 * 86400,
            tokenURI: "ipfs://QmR32iUNuydSrZT6eCxaWqH1NUxs77g9kiigzGDib7mFqY",
            pieces: pieces
        });

        GovernanceArgs memory gpGovArgs = GovernanceArgs({
            votingDelay: 1, // 1 block
            votingPeriod: 14400, // 2 days of blocks
            proposalThreshold: 1,
            timelockDelay: 1 days
        });

        GamePieceGovernorSimpleFactory gpFactory = GamePieceGovernorSimpleFactory(0xa44b9e680AE5a349D00d2ae58CeDC8612644A00b);
        PieceCollectorFactory pcFactory = PieceCollectorFactory(0xA9dBa4Ce1472a047325B0f2f0789318F09349446);
        vm.startBroadcast();
        PieceCollector pc = pcFactory.build(pcArgs);
        gpFactory.buildSimple(pc, gpGovArgs);
        vm.stopBroadcast();
    }
}
