// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {GamePiece} from "../src/GamePiece.sol";
import {Larpcoin} from "../src/Larpcoin.sol";

contract GamePieceTest is Test {
    GamePiece public piece;
    Larpcoin public larpcoin;
    uint256 public cost;
    address public owner;

    function setUp() public {
        owner = address(bytes20(hex"10000000"));
        cost = 100000e18;
        larpcoin = new Larpcoin("Larpcoin", "LARP", 1_000_000_000e18);
        piece = new GamePiece("GamePiece", "LGP", cost, address(larpcoin), 30 * 86400, "http://example.com", owner);
    }

    function testMint() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        vm.stopPrank();

        assertEq(piece.balanceOf(minter), 1);
        assertEq(piece.getVotes(minter), 1);
        assertEq(larpcoin.balanceOf(address(piece)), cost);
        assertEq(larpcoin.balanceOf(minter), 0);
    }

    /*
    function testOverpayingFails() public {
        address minter = address(1);
        vm.deal(minter, 1 ether);

        vm.prank(minter);
        vm.expectRevert();
        piece.mint();
    }

    function testUnderpayingFails() public {
        address minter = address(1);
        vm.deal(minter, 1 gwei);

        vm.prank(minter);
        vm.expectRevert();
        piece.mint();
    }
    */

    function testOwnerCanMintToAnyone() public {
        address recipient = address(2);
        vm.prank(owner);
        piece.mintTo(recipient);
        assertEq(piece.balanceOf(recipient), 1);
    }

    function testPublicCannotMintToAnyone() public {
        address recipient = address(2);
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.mintTo(recipient);
    }

    function testSetTokenURI() public {
        vm.prank(owner);
        piece.setTokenURI("data");

        address recipient = address(2);
        vm.prank(owner);
        piece.mintTo(recipient);

        assertEq(piece.tokenURI(1), "data");
    }

    function testPublicCannotSetTokenURI() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setTokenURI("data");
    }

    function testSetName() public {
        vm.prank(owner);
        piece.setName("Bitcoin");
        assertEq(piece.name(), "Bitcoin");
    }

    function testPublicCannotSetName() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setName("Bitcoin");
    }

    function testSetSymbol() public {
        vm.prank(owner);
        piece.setSymbol("BTC");
        assertEq(piece.symbol(), "BTC");
    }

    function testPublicCannotSetSymbol() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setSymbol("BTC");
    }

    function testSetCost() public {
        vm.prank(owner);
        piece.setCost(cost / 2);

        address minter = address(1);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        vm.stopPrank();

        assertEq(piece.balanceOf(minter), 1);
        assertEq(piece.getVotes(minter), 1);
        assertEq(larpcoin.balanceOf(address(piece)), cost / 2);
        assertEq(larpcoin.balanceOf(minter), cost / 2);
    }

    function testPublicCannotSetCost() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setCost(cost / 2);
    }

    function testMinterCanRegister() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        piece.delegate(minter);
        vm.stopPrank();

        assertEq(piece.getVotes(minter), 1);
    }

    function testTransferRecipientCanRegister() public {
        address minter = address(1);
        address recipient = address(2);
        larpcoin.transfer(minter, cost * 2);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 2);
        piece.mint();
        piece.mint();
        piece.transferFrom(minter, recipient, 2);
        vm.stopPrank();

        vm.prank(recipient);
        piece.delegate(recipient);

        assertEq(piece.getVotes(recipient), 1);
    }

    function testMinterCanRegisterBeforeMinting() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.delegate(minter);
        assertEq(piece.getVotes(minter), 0);

        piece.mint();
        vm.stopPrank();
        assertEq(piece.getVotes(minter), 1);
    }

    function testPlayerCantTransferActivePiece() public {
        address minter = address(1);
        address recipient = address(2);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        piece.delegate(minter);
        vm.expectRevert();
        piece.transferFrom(minter, recipient, 1);
        vm.stopPrank();
    }

    function testPlayerCanTransferSurplusPiece() public {
        address minter = address(1);
        address recipient = address(2);
        larpcoin.transfer(minter, cost * 2);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 2);
        piece.mint();
        piece.mint();
        piece.delegate(minter);
        piece.transferFrom(minter, recipient, 1);
        vm.stopPrank();

        assertEq(piece.getVotes(minter), 1);
        assertEq(piece.balanceOf(minter), 1);
        assertEq(piece.balanceOf(recipient), 1);
    }

    function testMinterOnlyGetsOneVote() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost * 5);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 5);
        piece.mint();
        piece.mint();
        piece.mint();
        piece.mint();
        piece.mint();
        piece.delegate(minter);
        vm.stopPrank();

        assertEq(piece.getVotes(minter), 1);
        assertEq(piece.balanceOf(minter), 5);
    }

    function testPlayerExpiresAfterRound() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        piece.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        piece.expirePlayers(accounts);
        assertEq(piece.getVotes(minter), 0);
    }

    function testPlayerDoesntExpireAfterRoundIfTheyMint() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost * 2);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 2);
        piece.mint();
        piece.delegate(minter);
        vm.warp(block.timestamp + 30 * 86400);
        piece.mint();
        vm.stopPrank();

        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        piece.expirePlayers(accounts);
        assertEq(piece.getVotes(minter), 1);
    }

    function testExpiredPlayerReactivates() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost * 2);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 2);
        piece.mint();
        piece.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        piece.expirePlayers(accounts);
        assertEq(piece.getVotes(minter), 0);

        vm.prank(minter);
        piece.mint();
        assertEq(piece.getVotes(minter), 1);
    }

    function testExpiredPlayerReactivatesAfterLongAbsence() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost * 2);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 2);
        piece.mint();
        piece.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        piece.expirePlayers(accounts);
        assertEq(piece.getVotes(minter), 0);

        vm.warp(block.timestamp + 30 * 86400 * 12);
        vm.prank(minter);
        piece.mint();
        assertEq(piece.getVotes(minter), 1);
    }

    function testReactivationExpires() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost * 2);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 2);
        piece.mint();
        piece.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        piece.expirePlayers(accounts);
        assertEq(piece.getVotes(minter), 0);

        vm.warp(block.timestamp + 30 * 86400 * 12);
        vm.prank(minter);
        piece.mint();
        assertEq(piece.getVotes(minter), 1);

        vm.warp(block.timestamp + 30 * 86400);
        piece.expirePlayers(accounts);
        assertEq(piece.getVotes(minter), 0);
    }

    function testOwnerCanLockMinting() public {
        vm.prank(owner);
        piece.setMintingLocked(true);
        assertEq(piece.mintingLocked(), true);

        address minter = address(1);
        larpcoin.transfer(minter, cost * 2);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 2);
        vm.expectRevert();
        piece.mint();
        vm.stopPrank();

        // Unlock minting and ensure we can mint again.
        vm.prank(owner);
        piece.setMintingLocked(false);
        assertEq(piece.mintingLocked(), false);

        vm.prank(minter);
        piece.mint();
        assertEq(piece.balanceOf(minter), 1);
    }

    function testPublicCannotLockMinting() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setMintingLocked(true);
    }

    function testOwnerCanDisableTransferLimits() public {
        address minter = address(1);
        address recipient = address(2);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        piece.delegate(minter);
        vm.expectRevert();
        piece.transferFrom(minter, recipient, 1);
        vm.stopPrank();

        vm.prank(owner);
        piece.setTransferLimitsDisabled(true);
        assertEq(piece.transferLimitsDisabled(), true);

        vm.prank(minter);
        piece.transferFrom(minter, recipient, 1);
        assertEq(piece.balanceOf(minter), 0);
        assertEq(piece.balanceOf(recipient), 1);
    }

    function testPublicCannotDisableTransferLimits() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setTransferLimitsDisabled(true);
    }
}
