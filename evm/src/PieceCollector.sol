// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/governance/utils/Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC4906.sol";

import {Slowlock} from "./Slowlock.sol";


struct PlayerRecord {    
    // The first time the player registered to vote. Never changes.
    uint256 firstTime;

    // The most recent time the player (re)activated.
    uint256 activationTime;
    uint256 tokenId;

    uint256 usedValue;
    uint256 expirationTime;

    bool isActive;
}

struct ValuablePiece {
    address nft;
    uint256 erc1155TokenId;
    uint256 value;
    string mintUrl;
    bool forceERC1155;
}

/**
 * PieceController is a nontransferable NFT that can be minted with the specified amount of ETH.
 * Its parameters can be updated by the owner of the NFT contract, which is intended to be the
 * LarpcoinGovernor.
 */
contract PieceCollector is ERC721, ERC721Enumerable, IERC4906, EIP712, ERC721Votes, Ownable {  
    // ERC721's name and symbol are private, so we can't edit them. We shadow them instead.
    string _name;
    string _symbol;

    uint256 public cost;
    uint256 public roundLength;
    string _tokenURI;

    mapping(address player => PlayerRecord) public playerRecords;
    mapping(uint256 pieceId => ValuablePiece piece) public pieces;
    uint256[] public pieceIds;
    uint256 nextTokenId = 1;
    uint256 nextPieceId = 1;

    event PlayerRegistered(address indexed account, uint256 indexed tokenId);
    event PlayerRegistrationExtended(address indexed account, uint256 indexed tokenId, uint256 expirationTime);
    event PlayerDeactivated(address indexed account, uint256 indexed tokenId);
    event PlayerReactivated(address indexed account, uint256 indexed tokenId);
    event PieceAdded(uint256 pieceId, address indexed nft, uint256 erc1155TokenId);
    event PieceRemoved(uint256 pieceId, address indexed nft, uint256 erc1155TokenId);

    error CannotTransferPieceCollector(address to, uint256 tokenId);
    error RemovePieceNotFound(uint256 pieceId);
    
    constructor(string memory name_, string memory symbol_, uint256 cost_, uint256 roundLength_, string memory tokenURI_, address initialOwner, ValuablePiece[] memory pieces_)
        ERC721(name_, symbol_)
        EIP712(name_, "1")
        Ownable(initialOwner)
    {
        
        _name = name_;
        _symbol = symbol_;
        
        cost = cost_;

        roundLength = roundLength_;
        _tokenURI = tokenURI_;

        for (uint256 i = 0; i < pieces_.length; i++) {
            pieceIds.push(nextPieceId);
            pieces[nextPieceId] = pieces_[i];
            nextPieceId++;
        }
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    
    function minimumRegistrationValue(address account) public view returns (uint256) {
        PlayerRecord storage record = playerRecords[account];
        if (record.expirationTime > block.timestamp) {
            return record.usedValue;
        }
        uint256 elapsedRounds = (block.timestamp - record.expirationTime) / roundLength + 1;
        return record.usedValue + (elapsedRounds * cost);
    }

    function activeUntil(address player) public view returns (uint256) {
        if (!playerRecords[player].isActive) {
            return 0;
        }
        uint256 usableValue = getTotalPieceValue(player) - playerRecords[player].usedValue;
        return playerRecords[player].expirationTime + (usableValue / cost) * roundLength;
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Votes)
        returns (address)
    {
        // Prohibit transfers except minting and burning.
        address from = _ownerOf(tokenId);
        if (to != address(0) && from != address(0)) {
            revert CannotTransferPieceCollector(to, tokenId);
        }
        
        return super._update(to, tokenId, auth);
    }

    function _delegate(address account, address delegatee) internal override {
        updatePlayer(account);
        return super._delegate(account, delegatee);
    }

    function getTotalPieceValue(address account) public view returns (uint256) {
        uint256 totalValue = 0;
        for (uint256 i = 0; i < pieceIds.length; i++) {
            ValuablePiece storage piece = pieces[pieceIds[i]];
            uint256 pieceBalance;
            if (piece.erc1155TokenId != 0 || piece.forceERC1155) {
                pieceBalance = IERC1155(piece.nft).balanceOf(account, piece.erc1155TokenId);
            } else {
                pieceBalance = IERC721(piece.nft).balanceOf(account);
            }
            totalValue += pieceBalance * piece.value;
        }
        return totalValue;
    }

    function registerPlayer(address account) internal {
        PlayerRecord storage record = playerRecords[account];
        record.firstTime = block.timestamp;
        record.activationTime = block.timestamp;
        record.usedValue = cost;
        record.expirationTime = block.timestamp + roundLength;
        record.isActive = true;

        // Mint the player's NFT.
        record.tokenId = nextTokenId++;
        _mint(account, record.tokenId);
        emit PlayerRegistered(account, record.tokenId);
    }

    function deactivatePlayer(address account) internal {
        PlayerRecord storage record = playerRecords[account];
        record.isActive = false;
        // Burn the player's NFT.
        _burn(record.tokenId);
        emit PlayerDeactivated(account, record.tokenId);
    }

    function advancePlayerRegistration(address account, uint256 totalValue) internal returns (bool){
        PlayerRecord storage record = playerRecords[account];
        bool advanced = false;
        while (true) {
            // Advance the expiration time until it's not in the past if the player has enough value.
            uint256 usableValue = totalValue - record.usedValue;
            if (usableValue >= cost && record.expirationTime <= block.timestamp) {
                record.usedValue += cost;
                record.expirationTime += roundLength;
                advanced = true;
                emit PlayerRegistrationExtended(account, record.tokenId, record.expirationTime);
            } else {
                break;
            }
        }
        return advanced;
    }

    function updatePlayer(address account) public {
        PlayerRecord storage record = playerRecords[account];
        uint256 value = getTotalPieceValue(account);

        if (record.firstTime == 0) {
            if (value < cost) {
                return;
            }

            registerPlayer(account);
            return;
        }

        if (record.isActive) {
            advancePlayerRegistration(account, value);

            uint256 registrationValue = minimumRegistrationValue(account);
            if (value < registrationValue) {
                deactivatePlayer(account);
            }
            return;
        }
        
        // We're updating an expired player. Try to reactivate them.
        if (!advancePlayerRegistration(account, value)) {
            return;
        }

        record.isActive = true;
        if (record.expirationTime >= block.timestamp) {
            // Mint the player's NFT with the same tokenId.
            _mint(account, record.tokenId);
        } else {
            // Reset the user's activation time and balance if they've been inactive more than
            // a full round. This allows a grace period of one round for players to reactivate
            // without losing their coveted activtion time.
            record.activationTime = block.timestamp;
            record.expirationTime = block.timestamp + roundLength;
            // Mint the player's NFT with a new tokenId.
            record.tokenId = nextTokenId++;
            _mint(account, record.tokenId);
        }
        emit PlayerReactivated(account, record.tokenId);
    }

    function updatePlayers(address[] calldata accounts) public {
        for (uint256 i = 0; i < accounts.length; i++) {
            updatePlayer(accounts[i]);
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        return _tokenURI;
    }

    function setTokenURI(string memory tokenURI_) onlyOwner public {
        _tokenURI = tokenURI_;
        emit BatchMetadataUpdate(1, type(uint256).max);
    }

    function setName(string memory name_) onlyOwner public {
        _name = name_;
    }

    function setSymbol(string memory symbol_) onlyOwner public {
        _symbol = symbol_;
    }

    function setCost(uint256 cost_) onlyOwner public {
        cost = cost_;
    }

    function setRoundLength(uint256 roundLength_) onlyOwner public {
        roundLength = roundLength_;
    }

    function addPiece(ValuablePiece calldata piece) onlyOwner public {
        pieceIds.push(nextPieceId);
        pieces[nextPieceId] = piece;
        emit PieceAdded(nextPieceId, piece.nft, piece.erc1155TokenId);
        nextPieceId++;
    }

    function removePiece(uint256 pieceId) onlyOwner public { 
        for (uint256 i = 0; i < pieceIds.length; i++) {
            if (pieceIds[i] == pieceId) {
                pieceIds[i] = pieceIds[pieceIds.length - 1];
                pieceIds.pop();
                emit PieceRemoved(pieceId, pieces[pieceId].nft, pieces[pieceId].erc1155TokenId);
                delete pieces[pieceId];
                return;
            }
        }
        
        revert RemovePieceNotFound(pieceId);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable, ERC721Votes)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
