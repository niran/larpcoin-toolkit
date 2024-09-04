// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ISwapRouter} from "../src/uniswap/ISwapRouter.sol";

import "../src/LarpcoinGameFactory.sol";
import {LarpcoinFactory, LarpcoinArgs} from "../src/subfactories/LarpcoinFactory.sol";
import {LarpcoinGovernorFactory} from "../src/subfactories/LarpcoinGovernorFactory.sol";
import {GamePieceFactory} from "../src/subfactories/GamePieceFactory.sol";
import {GamePieceGovernorFactory} from "../src/subfactories/GamePieceGovernorFactory.sol";
import {GovernanceArgs} from "../src/subfactories/GovernanceArgs.sol";
import {TimelockControllerFactory} from "../src/subfactories/TimelockControllerFactory.sol";
import {SlowlockFactory} from "../src/subfactories/SlowlockFactory.sol";
import {Larpcoin} from "../src/Larpcoin.sol";
import {GamePiece} from "../src/GamePiece.sol";
import {GamePieceGovernor} from "../src/GamePieceGovernor.sol";

import {SwapsForLarpcoins} from "./SwapsForLarpcoins.sol";


contract GamePieceGovernorTest is Test, SwapsForLarpcoins {
    LarpcoinGameFactory public factory;
    address public WETH9 = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;

    function setUp() public {
        LarpcoinFactory lcFactory = new LarpcoinFactory(
            0x1238536071E1c677A632429e3655c799b22cDA52,
            0x0227628f3F023bb0B980b67D528571c95c6DaC1c,
            0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14
        );
        TimelockControllerFactory tcFactory = new TimelockControllerFactory();
        SlowlockFactory slowlockFactory = new SlowlockFactory();
        GamePieceFactory gpFactory = new GamePieceFactory();
        LarpcoinGovernorFactory lcGovFactory = new LarpcoinGovernorFactory(address(tcFactory));
        GamePieceGovernorFactory gpGovFactory = new GamePieceGovernorFactory(address(tcFactory), address(slowlockFactory), address(gpFactory));
        factory = new LarpcoinGameFactory(address(lcFactory), address(lcGovFactory), address(gpGovFactory));

        vm.makePersistent(address(lcFactory));
        vm.makePersistent(address(tcFactory));
        vm.makePersistent(address(slowlockFactory));
        vm.makePersistent(address(gpFactory));
        vm.makePersistent(address(lcGovFactory));
        vm.makePersistent(address(gpGovFactory));
        vm.makePersistent(address(factory));
    }

    function buildContracts() internal returns (LarpcoinContracts memory) {
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
            cost: 100000e18,
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
        return factory.build(lcArgs, gpArgs, lcGovArgs, gpGovArgs, 1460 /* 4 years in days */);    }

    function mintAndDelegate(address account, GamePiece piece, Larpcoin larpcoin) internal {
        larpcoin.transfer(address(account), 100000e18);
        vm.startPrank(account);
        larpcoin.approve(address(piece), 100000e18);
        piece.mint();
        piece.delegate(account);
        vm.stopPrank();
    }

    function executeViaGPGov(LarpcoinContracts memory c, address target, uint256 value, bytes memory data, string memory description) internal {
        address proposer = address(1);
        address[4] memory voters = [address(2), address(3), address(4), address(5)];
        mintAndDelegate(proposer, c.piece, c.larpcoin);
        for (uint256 i = 0; i < voters.length; i++) {
            mintAndDelegate(voters[i], c.piece, c.larpcoin);
        }
        
        // Delegation takes effect on the next block.
        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        targets[0] = target;
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = data;
        vm.prank(proposer);
        uint256 proposalId = c.gpGov.propose(targets, values, calldatas, description);

        // Advance blocks to the voting period.
        vm.roll(block.number + 7200 + 1);
        vm.prank(proposer);
        c.gpGov.castVote(proposalId, 1);
        for (uint256 i = 0; i < voters.length; i++) {
            vm.prank(voters[i]);
            c.gpGov.castVote(proposalId, 1);
        }

        // Advance blocks past the end of the voting period.
        vm.roll(block.number + 50400 + 1);
        c.gpGov.queue(targets, values, calldatas, keccak256(bytes(description)));

        // Advance seconds past the timelock delay.
        vm.warp(block.timestamp + 86400 + 1);
        c.gpGov.execute(targets, values, calldatas, keccak256(bytes(description)));
    }

    function testGPGovCanPassProposals() public {
        vm.createSelectFork("https://ethereum-sepolia-rpc.publicnode.com");
        LarpcoinContracts memory c = buildContracts();
        swapForLarpcoins(address(c.larpcoin));
        vm.warp(block.timestamp + 365 days * 4);
        c.slowlock.stream();

        address dest = address(1);
        executeViaGPGov(c, address(c.larpcoin), 0, abi.encodeCall(c.larpcoin.transfer, (dest, 100_000_000e18)), "Send larpcoins to destination");
        assertEq(c.larpcoin.balanceOf(dest), 100_000_000e18);
    }
}
