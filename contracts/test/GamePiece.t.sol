// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {GamePiece} from "../src/GamePiece.sol";
import {Larpcoin} from "../src/Larpcoin.sol";
import {Slowlock} from "../src/Slowlock.sol";


contract GamePieceTest is Test {
    GamePiece public piece;
    Larpcoin public larpcoin;
    Slowlock public slowlock;
    uint256 public cost;
    address public owner;

    function setUp() public {
        owner = address(bytes20(hex"10000000"));
        cost = 100000e18;
        larpcoin = new Larpcoin("Larpcoin", "LARP", 1_000_000_000e18);
        // Set up a slowlock with a half-life of 1460 days (4 years)
        uint256[] memory decayFactorsX96 = new uint256[](32);
        decayFactorsX96[0] = 79228162078914441309719934688;
        decayFactorsX96[1] = 79228161643564547418094932367;
        decayFactorsX96[2] = 79228160772864766811441915127;
        decayFactorsX96[3] = 79228159031465234304523462198;
        decayFactorsX96[4] = 79228155548666284116233938090;
        decayFactorsX96[5] = 79228148583068843041820861280;
        decayFactorsX96[6] = 79228134651875798101470148507;
        decayFactorsX96[7] = 79228106789497057053162928428;
        decayFactorsX96[8] = 79228051064768970274064850710;
        decayFactorsX96[9] = 79227939615430377889450533232;
        decayFactorsX96[10] = 79227716717223517042681373586;
        decayFactorsX96[11] = 79227270922691084864054230083;
        decayFactorsX96[12] = 79226379341151329167291428200;
        decayFactorsX96[13] = 79224596208171857226675353705;
        decayFactorsX96[14] = 79221030062609909711338197416;
        decayFactorsX96[15] = 79213898253048709645592272659;
        decayFactorsX96[16] = 79199636559974782460104488323;
        decayFactorsX96[17] = 79171120876402637733399339858;
        decayFactorsX96[18] = 79114120306620099238407527035;
        decayFactorsX96[19] = 79000242253043198113616295780;
        decayFactorsX96[20] = 78772977663288196192260323272;
        decayFactorsX96[21] = 78320407958769867298286407057;
        decayFactorsX96[22] = 77423053976845087024027954998;
        decayFactorsX96[23] = 75659072441850980625774594763;
        decayFactorsX96[24] = 72250763631311596104176760411;
        decayFactorsX96[25] = 65887844418552707959198118407;
        decayFactorsX96[26] = 54793748893795318028937065452;
        decayFactorsX96[27] = 37895046692465547197822484357;
        decayFactorsX96[28] = 18125304415151601519199277294;
        decayFactorsX96[29] = 4146589416140577390039863934;
        decayFactorsX96[30] = 217021362611475288349078760;
        decayFactorsX96[31] = 594463765599281850667483;
        slowlock = new Slowlock(owner, address(100), address(larpcoin), decayFactorsX96);
        piece = new GamePiece("GamePiece", "LGP", cost, address(larpcoin), address(slowlock), 30 * 86400, "http://example.com", owner);
    }

    function testMint() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        vm.stopPrank();

        assertEq(piece.balanceOf(minter), 1);
        assertEq(piece.getVotes(minter), 0);
        assertGt(larpcoin.balanceOf(address(slowlock)), 0);
        assertEq(larpcoin.balanceOf(minter), 0);
    }

    function testMintFailsWithoutEnoughMoney() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost / 2);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        vm.expectRevert();
        piece.mint();
        vm.stopPrank();

        assertEq(piece.balanceOf(minter), 0);
    }

    function testMintAndPlay() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mintAndPlay();
        vm.stopPrank();

        assertEq(piece.balanceOf(minter), 1);
        assertEq(piece.getVotes(minter), 1);
        assertEq(piece.activeUntil(minter), block.timestamp + 30 * 86400);
        assertGt(larpcoin.balanceOf(address(slowlock)), 0);
        assertEq(larpcoin.balanceOf(minter), 0);
    }

    function testMintPieces() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost * 10);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 10);
        piece.mintPieces(10);
        vm.stopPrank();

        assertEq(piece.balanceOf(minter), 10);
        assertEq(piece.getVotes(minter), 0);
        assertGt(larpcoin.balanceOf(address(slowlock)), 0);
        assertEq(larpcoin.balanceOf(minter), 0);
    }

    function testMintPiecesFailsWithoutEnoughMoney() public {
        address minter = address(1);
        larpcoin.transfer(minter, cost * 9);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost * 10);
        vm.expectRevert();
        piece.mintPieces(10);
        vm.stopPrank();

        assertEq(piece.balanceOf(minter), 0);
    }

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
        assertEq(larpcoin.balanceOf(address(slowlock)), cost / 2);
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
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        piece.transferFrom(minter, recipient, 1);
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

        assertEq(piece.activeUntil(minter), block.timestamp + 60 * 86400);
        piece.transferFrom(minter, recipient, 1);
        assertEq(piece.activeUntil(minter), block.timestamp + 30 * 86400);


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
        assertEq(piece.activeUntil(minter), 0);
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
        uint256 activationTime = block.timestamp;
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
        (, uint256 updatedActivationTime, , ) = piece.playerRecords(minter);
        assertEq(updatedActivationTime, activationTime);
    }

    function testExpiredPlayerReactivatesAfterLongAbsence() public {
        address minter = address(1);
        uint256 activationTime = block.timestamp;
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
        (, uint256 updatedActivationTime, , ) = piece.playerRecords(minter);
        assertGt(updatedActivationTime, activationTime);
        assertEq(piece.activeUntil(minter), updatedActivationTime + 30 * 86400);
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

    function testOwnerCanSetSlowlock() public {
        address newSlowlock = address(7);
        vm.prank(owner);
        piece.setSlowlock(newSlowlock);
        assertEq(address(piece.slowlock()), newSlowlock);
    }

    function testPublicCannotSetSlowlock() public {
        address hacker = address(3);
        address newSlowlock = address(7);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setSlowlock(newSlowlock);
    }

    function testOwnerCanSetStreamOnMint() public {
        vm.prank(owner);
        piece.setStreamOnMint(false);
        assertEq(piece.streamOnMint(), false);

        vm.warp(block.timestamp + 1);

        address minter = address(1);
        larpcoin.transfer(minter, cost);

        vm.startPrank(minter);
        larpcoin.approve(address(piece), cost);
        piece.mint();
        vm.stopPrank();

        assertEq(piece.balanceOf(minter), 1);
        assertEq(piece.getVotes(minter), 0);
        assertEq(larpcoin.balanceOf(address(slowlock)), cost);
        assertEq(larpcoin.balanceOf(minter), 0);

        slowlock.stream();
        assertLt(larpcoin.balanceOf(address(slowlock)), cost);
    }

    function testPublicCannotSetStreamOnMint() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setStreamOnMint(false);
    }
}
