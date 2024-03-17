// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * PlayerPiece is a nontransferable NFT that can be minted with the specified amount of ETH.
 * Its parameters can be updated by the owner of the NFT contract, which is intended to be the
 * LarpcoinGovernor.
 */
contract PlayerPiece is ERC721, EIP712, ERC721Votes, Ownable {
    struct PlayerRecord {
        uint256 id;
    }
    
    // ERC721's name and symbol are private, so we can't edit them. We shadow them instead.
    string _name;
    string _symbol;

    uint256 _cost;
    string _tokenURI;
    uint256 _nextPlayerId;
    mapping(address player => PlayerRecord) _playerRecords;

    error PlayerPieceIncorrectMintPayment(uint256 expectedPayment, uint256 actualPayment);
    error PlayerPieceAlreadyMinted(address minter, PlayerRecord record);
    error PlayerPieceTransfersProhibited(address from, address to);
    
    constructor(string memory name_, string memory symbol_, uint256 cost_, string memory tokenURI_, address initialOwner)
        ERC721(name_, symbol_)
        EIP712(name_, "1")
        Ownable(initialOwner)
    {
        
        _name = name_;
        _symbol = symbol_;
        _cost = cost_;
        _tokenURI = tokenURI_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function mint() public payable {
        if (msg.value != _cost) {
            revert PlayerPieceIncorrectMintPayment(_cost, msg.value);
        }

        _mintTo(msg.sender);
    }

    function mintTo(address to) public onlyOwner {
        _mintTo(to);
    }

    function _mintTo(address to) internal {
        if (balanceOf(to) != 0) {
            revert PlayerPieceAlreadyMinted(to, _playerRecords[to]);
        }

        PlayerRecord storage record = _playerRecords[to];
        if (record.id == 0) {
            record.id = ++_nextPlayerId;
        }

        _safeMint(to, record.id);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Votes)
        returns (address)
    {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert PlayerPieceTransfersProhibited(from, to);
        }
        
        return super._update(to, tokenId, auth);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        return _tokenURI;
    }

    function setTokenURI(string memory tokenURI_) onlyOwner public {
        _tokenURI = tokenURI_;
    }

    function setName(string memory name_) onlyOwner public {
        _name = name_;
    }

    function setSymbol(string memory symbol_) onlyOwner public {
        _symbol = symbol_;
    }

    function setCost(uint256 cost_) onlyOwner public {
        _cost = cost_;
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Votes)
    {
        super._increaseBalance(account, value);
    }
}
