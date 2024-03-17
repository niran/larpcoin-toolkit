// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";

import {LarpcoinFactory} from "../src/LarpcoinFactory.sol";
import {Larpcoin} from "../src/Larpcoin.sol";
import {PlayerPiece} from "../src/PlayerPiece.sol";
import {LarpcoinGovernor} from "../src/LarpcoinGovernor.sol";
import {PlayerGovernor} from "../src/PlayerGovernor.sol";


contract LarpcoinFactoryTest is Test {
    LarpcoinFactory public factory;

    function setUp() public {
        factory = new LarpcoinFactory();
    }

    function testBuild() public {
        (
            PlayerPiece piece,
            Larpcoin larpcoin,
            TimelockController pHouse,
            TimelockController fpHouse,
            PlayerGovernor playerGov,
            LarpcoinGovernor coinGov
        ) = factory.build("Larpcoin", "LARP", 1_000_000_000, "PlayerPiece", "LPP", 0.001 ether,
            "http://example.com", 7200 /* 1 day */);
    }
}
