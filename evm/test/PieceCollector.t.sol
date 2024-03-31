// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import {Test, console} from "forge-std/Test.sol";
import {PieceCollector, ValuablePiece} from "../src/PieceCollector.sol";
import {Larpcoin} from "../src/Larpcoin.sol";
import {Slowlock} from "../src/Slowlock.sol";

contract ZoraNFT is ERC1155 {
    constructor(string memory uri) ERC1155(uri) {}

    function mint(uint256 id) public {
        return _mint(msg.sender, id, 1, "");
    }
}

contract ManifoldNFT is ERC721 {
    constructor() ERC721("ManifoldNFT", "MANIFOLD") {}

    function mint(uint256 tokenId) public {
        return _mint(msg.sender, tokenId);
    }
}

contract PieceCollectorTest is Test {
    PieceCollector public pc;
    uint256 public cost;
    address public owner;
    ZoraNFT zoraNFT;
    ManifoldNFT manifoldNFT;
    uint256 tokenId = 1;

    function setUp() public {
        owner = address(bytes20(hex"10000000"));
        cost = 100000e18;

        zoraNFT = new ZoraNFT("http://example.com");
        manifoldNFT = new ManifoldNFT();
        ValuablePiece[] memory pieces = new ValuablePiece[](2);
        pieces[0] = ValuablePiece({
            nft: address(zoraNFT),
            erc1155TokenId: tokenId,
            value: 100000e18,
            mintUrl: "http://example.com/mint",
            forceERC1155: true
        });
        pieces[1] = ValuablePiece({
            nft: address(manifoldNFT),
            erc1155TokenId: 0,
            value: 100000e18,
            mintUrl: "http://example.com/mint",
            forceERC1155: false
        });
        pc = new PieceCollector("PieceCollector", "PCL", cost, 30 * 86400, "http://example.com", owner, pieces);
    }

    function testMint() public {
        address minter = address(1);

        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        assertEq(pc.balanceOf(minter), 1);
        assertEq(pc.getVotes(minter), 1);
    }

    function testMint721() public {
        address minter = address(1);

        vm.startPrank(minter);
        manifoldNFT.mint(1);
        pc.delegate(minter);
        vm.stopPrank();

        assertEq(pc.balanceOf(minter), 1);
        assertEq(pc.getVotes(minter), 1);
    }

    function testSetTokenURI() public {
        vm.prank(owner);
        pc.setTokenURI("data");

        address minter = address(1);
        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        assertEq(pc.tokenURI(1), "data");
    }

    function testPublicCannotSetTokenURI() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        pc.setTokenURI("data");
    }

    function testSetName() public {
        vm.prank(owner);
        pc.setName("Bitcoin");
        assertEq(pc.name(), "Bitcoin");
    }

    function testPublicCannotSetName() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        pc.setName("Bitcoin");
    }

    function testSetSymbol() public {
        vm.prank(owner);
        pc.setSymbol("BTC");
        assertEq(pc.symbol(), "BTC");
    }

    function testPublicCannotSetSymbol() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        pc.setSymbol("BTC");
    }

    function testSetCost() public {
        vm.prank(owner);
        pc.setCost(cost * 2);

        address minter = address(1);
        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        assertEq(zoraNFT.balanceOf(minter, tokenId), 1);
        assertEq(pc.balanceOf(minter), 0);
        assertEq(pc.getVotes(minter), 0);
    }

    function testPublicCannotSetCost() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        pc.setCost(cost / 2);
    }

    function testSetRoundLength() public {
        vm.prank(owner);
        pc.setRoundLength(7 * 86400);

        address minter = address(1);
        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 7 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        pc.updatePlayers(accounts);

        assertEq(pc.balanceOf(minter), 0);
        assertEq(pc.getVotes(minter), 0);
        assertEq(pc.activeUntil(minter), 0);
    }

    function testPublicCannotSetRoundLength() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        pc.setRoundLength(7 * 86400);
    }

    function testAddPiece() public {
        ZoraNFT newNFT = new ZoraNFT("http://example.com/new");
        ValuablePiece memory newPiece = ValuablePiece({
            nft: address(newNFT),
            erc1155TokenId: tokenId,
            value: 500000e18,
            mintUrl: "http://example.com/mint",
            forceERC1155: true
        });

        vm.prank(owner);
        pc.addPiece(newPiece);

        address minter = address(1);
        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        assertEq(zoraNFT.balanceOf(minter, tokenId), 1);
        assertEq(pc.balanceOf(minter), 1);
        assertEq(pc.getVotes(minter), 1);
    }

    function testPublicCannotAddPiece() public {
        ZoraNFT newNFT = new ZoraNFT("http://example.com/new");
        ValuablePiece memory newPiece = ValuablePiece({
            nft: address(newNFT),
            erc1155TokenId: 0,
            value: 500000e18,
            mintUrl: "http://example.com/mint",
            forceERC1155: false
        });

        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        pc.addPiece(newPiece);
    }

    function testRemovePiece() public {
        vm.prank(owner);
        pc.removePiece(1);

        address minter = address(1);
        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        assertEq(zoraNFT.balanceOf(minter, tokenId), 1);
        assertEq(pc.balanceOf(minter), 0);
        assertEq(pc.getVotes(minter), 0);
    }

    function testCannotRemoveUnknownPiece() public {
        vm.prank(owner);
        vm.expectRevert();
        pc.removePiece(1000);
    }

    function testPublicCannotRemovePiece() public {
        address hacker = address(3);
        vm.prank(hacker);
        vm.expectRevert();
        pc.removePiece(0);
    }

    function testPlayerCannotTransfer() public {
        address minter = address(1);
        address recipient = address(2);

        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.expectRevert();
        pc.transferFrom(minter, recipient, tokenId);
        vm.stopPrank();
    }

    function testMinterOnlyGetsOneVote() public {
        address minter = address(1);

        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        zoraNFT.mint(tokenId);
        zoraNFT.mint(tokenId);
        zoraNFT.mint(tokenId);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        assertEq(pc.getVotes(minter), 1);
        assertEq(pc.balanceOf(minter), 1);
        assertEq(zoraNFT.balanceOf(minter, tokenId), 5);
    }

    function testPlayerExpiresAfterRound() public {
        address minter = address(1);

        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        pc.updatePlayers(accounts);

        assertEq(pc.balanceOf(minter), 0);
        assertEq(pc.getVotes(minter), 0);
        assertEq(pc.activeUntil(minter), 0);
    }

    function testPlayerDoesntExpireAfterRoundIfTheyMint() public {
        address minter = address(1);
        uint256 activationTime = block.timestamp;

        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.warp(block.timestamp + 30 * 86400);
        zoraNFT.mint(tokenId);
        vm.stopPrank();

        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        pc.updatePlayers(accounts);
        assertEq(pc.getVotes(minter), 1);
        (, uint256 updatedActivationTime, uint256 updatedTokenId , , ,) = pc.playerRecords(minter);
        assertEq(updatedActivationTime, activationTime);
        assertEq(updatedTokenId, tokenId);
    }

    function testExpiredPlayerReactivates() public {
        address minter = address(1);
        uint256 activationTime = block.timestamp;
        
        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        pc.updatePlayers(accounts);
        assertEq(pc.getVotes(minter), 0);

        vm.prank(minter);
        zoraNFT.mint(tokenId);
        pc.updatePlayers(accounts);

        assertEq(pc.getVotes(minter), 1);
        (, uint256 updatedActivationTime, uint256 updatedTokenId , , ,) = pc.playerRecords(minter);
        assertEq(updatedActivationTime, activationTime);
        assertEq(updatedTokenId, tokenId);
    }

    function testExpiredPlayerReactivatesAfterLongAbsence() public {
        address minter = address(1);
        uint256 activationTime = block.timestamp;

        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        pc.updatePlayers(accounts);
        assertEq(pc.getVotes(minter), 0);

        vm.warp(block.timestamp + 30 * 86400 * 12);
        vm.prank(minter);
        zoraNFT.mint(tokenId);
        pc.updatePlayers(accounts);

        assertEq(pc.getVotes(minter), 1);
        (, uint256 updatedActivationTime, uint256 updatedTokenId , , ,) = pc.playerRecords(minter);
        assertGt(updatedActivationTime, activationTime);
        assertGt(updatedTokenId, tokenId);
        assertEq(pc.activeUntil(minter), updatedActivationTime + 30 * 86400);
    }

    function testReactivationExpires() public {
        address minter = address(1);

        vm.startPrank(minter);
        zoraNFT.mint(tokenId);
        pc.delegate(minter);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 * 86400);
        address[] memory accounts = new address[](1);
        accounts[0] = minter;
        pc.updatePlayers(accounts);
        assertEq(pc.getVotes(minter), 0);

        vm.warp(block.timestamp + 30 * 86400 * 12);
        vm.prank(minter);
        zoraNFT.mint(tokenId);
        pc.updatePlayers(accounts);
        assertEq(pc.getVotes(minter), 1);

        vm.warp(block.timestamp + 30 * 86400);
        pc.updatePlayers(accounts);
        assertEq(pc.getVotes(minter), 0);
    }
}
