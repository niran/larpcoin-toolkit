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
            cost: 0.001 ether,
            tokenURI: "http://example.com"
        });
        return factory.build(lcArgs, gpArgs, 86400 /* 1 day */);
    }

    function executeViaLCGov(LarpcoinContracts memory c, address target, uint256 value, bytes memory data, string memory description) internal {
        address proposer = address(1);
        c.larpcoin.transfer(proposer, 1000e18);
        vm.prank(proposer);
        c.larpcoin.delegate(proposer);

        address quorumVoter = address(2);
        c.larpcoin.transfer(quorumVoter, 4000e18);
        vm.prank(quorumVoter);
        c.larpcoin.delegate(quorumVoter);
        
        // Delegation takes effect on the next block.
        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        targets[0] = target;
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = data;
        vm.prank(proposer);
        uint256 proposalId = c.lcGov.propose(targets, values, calldatas, description);

        // Advance blocks to the voting period.
        vm.roll(block.number + 7200 + 1);
        vm.prank(proposer);
        c.lcGov.castVote(proposalId, 1);
        vm.prank(quorumVoter);
        c.lcGov.castVote(proposalId, 1);

        // Advance blocks past the end of the voting period.
        vm.roll(block.number + 50400 + 1);
        c.lcGov.queue(targets, values, calldatas, keccak256(bytes(description)));

        // Advance seconds past the timelock delay.
        vm.warp(block.timestamp + 86400 + 1);
        c.lcGov.execute(targets, values, calldatas, keccak256(bytes(description)));
    }

    function testLCGovCanPassProposals() public {
        LarpcoinContracts memory c = buildContracts();
        executeViaLCGov(c, address(c.piece), 0, abi.encodeCall(c.piece.setName, ("NEWNAME")), "Change the name of the GamePiece to NEWNAME");
        assertEq(c.piece.name(), "NEWNAME");
    }
}
