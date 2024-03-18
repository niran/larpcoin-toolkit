// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";

import "../src/LarpcoinFactory.sol";
import {Larpcoin} from "../src/Larpcoin.sol";
import {GamePiece} from "../src/GamePiece.sol";
import {LarpcoinGovernor} from "../src/LarpcoinGovernor.sol";
import {GamePieceGovernor} from "../src/GamePieceGovernor.sol";


contract LarpcoinFactoryTest is Test {
    LarpcoinFactory public factory;

    function setUp() public {
        factory = new LarpcoinFactory();
    }

    function buildContracts() internal returns (LarpcoinContracts memory) {
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
        return factory.build(lcArgs, gpArgs, 86400 /* 1 day */);
    }

    function testBuild() public {
        LarpcoinContracts memory c = buildContracts();

        assertEq(c.larpcoin.totalSupply(), 1_000_000_000e18);
        assertEq(c.larpcoin.balanceOf(address(this)), 1_000_000_000e18);
        assertEq(c.piece.owner(), address(c.lcHouse));
        assertTrue(c.gpHouse.hasRole(c.gpHouse.PROPOSER_ROLE(), address(c.gpGov)));
        assertTrue(c.gpHouse.hasRole(c.gpHouse.CANCELLER_ROLE(), address(c.gpGov)));
        assertTrue(c.lcHouse.hasRole(c.lcHouse.PROPOSER_ROLE(), address(c.lcGov)));
        assertTrue(c.lcHouse.hasRole(c.lcHouse.CANCELLER_ROLE(), address(c.lcGov)));
    }
}
