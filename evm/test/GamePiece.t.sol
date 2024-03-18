// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {GamePiece} from "../src/GamePiece.sol";

contract GamePieceTest is Test {
    GamePiece public piece;
    address public owner;

    function setUp() public {
        owner = address(bytes20(hex"10000000"));
        piece = new GamePiece("GamePiece", "LGP", 0.001 ether, 30 * 86400, "http://example.com", owner);
    }

    function testMint() public {
        address minter = address(1);
        vm.deal(minter, 0.001 ether);
        vm.prank(minter);
        piece.mint{value: 0.001 ether}();
        assertEq(piece.balanceOf(minter), 1);
        assertEq(address(piece).balance, 0.001 ether);
    }

    function testOverpayingFails() public {
        address minter = address(1);
        vm.deal(minter, 1 ether);

        vm.prank(minter);
        vm.expectRevert();
        piece.mint{value: 1 ether}();
    }

    function testUnderpayingFails() public {
        address minter = address(1);
        vm.deal(minter, 1 gwei);

        vm.prank(minter);
        vm.expectRevert();
        piece.mint{value: 1 gwei}();
    }

    function testTransfersProhibited() public {
        address minter = address(1);
        vm.deal(minter, 0.001 ether);
        vm.prank(minter);
        piece.mint{value: 0.001 ether}();
        assertEq(piece.balanceOf(minter), 1);
        assertEq(address(piece).balance, 0.001 ether);

        address recipient = address(2);
        vm.prank(minter);
        vm.expectRevert();
        piece.transferFrom(minter, recipient, 1);
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
        piece.setCost(1 ether);

        address minter = address(1);
        vm.deal(minter, 1 ether);
        vm.prank(minter);
        piece.mint{value: 1 ether}();
        assertEq(piece.balanceOf(minter), 1);
        assertEq(address(piece).balance, 1 ether);
    }

    function testPublicCannotSetCost() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        piece.setCost(1 ether);
    }
}
