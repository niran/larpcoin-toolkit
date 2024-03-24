// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";

import "../src/LarpcoinGameFactory.sol";
import {LarpcoinFactory, LarpcoinArgs} from "../src/subfactories/LarpcoinFactory.sol";
import {LarpcoinGovernorFactory} from "../src/subfactories/LarpcoinGovernorFactory.sol";
import {GamePieceFactory} from "../src/subfactories/GamePieceFactory.sol";
import {GamePieceGovernorFactory} from "../src/subfactories/GamePieceGovernorFactory.sol";
import {GovernanceArgs} from "../src/subfactories/GovernanceArgs.sol";
import {TimelockControllerFactory} from "../src/subfactories/TimelockControllerFactory.sol";
import {SlowlockFactory} from "../src/subfactories/SlowlockFactory.sol";
import {GamePiece} from "../src/GamePiece.sol";
import {LarpcoinGovernor} from "../src/LarpcoinGovernor.sol";
import {GamePieceGovernor} from "../src/GamePieceGovernor.sol";


contract DeployAllFactories is Script {
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
            liquidityDestination: address(0xdead) // burn address
        });
        GamePieceArgs memory gpArgs = GamePieceArgs({
            name: "GamePiece",
            symbol: "LGP",
            cost: 250_000e18,
            roundLength: 30 * 86400,
            tokenURI: "http://example.com"
        });
        GovernanceArgs memory lcGovArgs = GovernanceArgs({
            votingDelay: 7200, // 1 day of blocks
            votingPeriod: 50400, // 1 week of blocks
            proposalThreshold: 1000e18,
            timelockDelay: 1 days
        });
        GovernanceArgs memory gpGovArgs = GovernanceArgs({
            votingDelay: 7200, // 1 day of blocks
            votingPeriod: 50400, // 1 week of blocks
            proposalThreshold: 1,
            timelockDelay: 1 days
        });

        LarpcoinGameFactory factory = LarpcoinGameFactory(0x6115007e9FF5a691174743a68F7b4855Ca190074);
        vm.startBroadcast();
        factory.build(lcArgs, gpArgs, lcGovArgs, gpGovArgs, 1460 /* 4 years in days */);
        vm.stopBroadcast();
    }
}
