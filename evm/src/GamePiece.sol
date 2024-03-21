// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/governance/utils/Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


struct PlayerRecord {    
    // The first time the player registered to vote. Never changes.
    uint256 firstTime;

    // The most recent time the player (re)activated.
    uint256 activationTime;

    // The player's balance at reactivation.
    uint256 activationBalance;

    bool isActive;
}

/**
 * GamePiece is a nontransferable NFT that can be minted with the specified amount of ETH.
 * Its parameters can be updated by the owner of the NFT contract, which is intended to be the
 * LarpcoinGovernor.
 */
contract GamePiece is ERC721, ERC721Enumerable, EIP712, Votes, Ownable {  
    // ERC721's name and symbol are private, so we can't edit them. We shadow them instead.
    string _name;
    string _symbol;

    uint256 _cost;
    uint256 _roundLength;
    string _tokenURI;

    bool public mintingLocked;
    bool public transferLimitsDisabled;

    mapping(address player => PlayerRecord) public playerRecords;

    error GamePieceIncorrectMintPayment(uint256 expectedPayment, uint256 actualPayment);
    error GamePieceBelowMinimumVotingBalance(address from, uint256 minimum);
    error GamePieceMintingLocked();

    event PlayerRegistered(address indexed account);
    event PlayerRegistrationExpired(address indexed account, uint256 minimum, uint256 actual);
    event PlayerReactivated(address indexed account);
    
    constructor(string memory name_, string memory symbol_, uint256 cost_, uint256 roundLength_, string memory tokenURI_, address initialOwner)
        ERC721(name_, symbol_)
        EIP712(name_, "1")
        Ownable(initialOwner)
    {
        
        _name = name_;
        _symbol = symbol_;
        _cost = cost_;
        _roundLength = roundLength_;
        _tokenURI = tokenURI_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function roundLength() public view returns (uint256) {
        return _roundLength;
    }

    function mint() public payable {
        if (msg.value != _cost) {
            revert GamePieceIncorrectMintPayment(_cost, msg.value);
        }

        _mintTo(msg.sender);
    }

    function mintTo(address to) public onlyOwner {
        _mintTo(to);
    }

    function _mintTo(address to) internal {
        if (mintingLocked) {
            revert GamePieceMintingLocked();
        }
        _safeMint(to, totalSupply() + 1);

        // Delegate the minter on their first mint. This has two side effects:
        // 1) This makes transfers cost more gas, which is fine for our use case.
        //    Collectors can undelegate if they're not playing with us.
        // 2) The first GamePiece that a collector mints will always be locked immediately.
        //    This isn't the desired behavior, but it's better than making players remember
        //    to register to vote. (New players who receive game pieces through a transfer still
        //    need to register.)
        if (playerRecords[to].firstTime == 0) {
            _delegate(to, to);
        }
    }

    function minimumVotingBalance(address player) public view returns (uint256) {
        uint256 elapsedRounds = (block.timestamp - playerRecords[player].activationTime) / _roundLength;
        return elapsedRounds + playerRecords[player].activationBalance + 1;
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        // Prohibit transfers that would reduce a registered player's balance below one per round.
        // NOTE: Accounts that haven't registered by calling `delegate()` can transfer game pieces
        // without restriction.
        address from = _ownerOf(tokenId);
        bool fromPlayer = playerRecords[from].firstTime != 0;
        if (!transferLimitsDisabled && fromPlayer && balanceOf(from) <= minimumVotingBalance(from)) {
            revert GamePieceBelowMinimumVotingBalance(from, minimumVotingBalance(from));
        }

        address previousOwner = super._update(to, tokenId, auth);

        // Unlike ERC721Votes, the only transfers that change votes for us are reactivations due to
        // the transfer restrictions above.
        PlayerRecord storage toRecord = playerRecords[to];
        bool toPlayer = toRecord.firstTime != 0;
        if (toPlayer && !toRecord.isActive) {
            // An expired player has acquired another game piece. Re-register them as an
            // active user.
            toRecord.activationTime = block.timestamp;
            toRecord.activationBalance = balanceOf(to) - 1;
            toRecord.isActive = true;
            _transferVotingUnits(address(0), to, 1);
            emit PlayerReactivated(to);
        }

        return previousOwner;
    }

    function _getVotingUnits(address account) internal view virtual override returns (uint256) {
        return playerRecords[account].isActive ? 1 : 0;
    }

    function _delegate(address account, address delegatee) internal virtual override {
        PlayerRecord storage record = playerRecords[account];
        if (record.firstTime == 0) {
            record.firstTime = block.timestamp;
            record.activationTime = block.timestamp;
            record.activationBalance = 0;
            if (balanceOf(account) > 0) {
                // Mint a new voting unit to the total supply of voting units since we're adding a
                // new voter. `super._delegate()` adds a voting unit for the player, but doesn't add
                // one to the total supply checkpoint.
                _transferVotingUnits(address(0), account, 1);
                record.isActive = true;
            } else {
                record.isActive = false;
            }
            emit PlayerRegistered(account);
        }

        super._delegate(account, delegatee);
    }

    /**
     * Remove voting rights from the given expired players.
     *
     * Registrations expire when the player's game piece balance is equal to the number of elapsed
     * periods. This function must be called manually to remove voting rights.
     */
    function expirePlayers(address[] calldata accounts) public {
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            if (getVotes(account) == 0) {
                continue;
            }

            PlayerRecord storage record = playerRecords[account];
            uint256 expected = minimumVotingBalance(account);
            uint256 actual = balanceOf(account);
            if (expected > actual) {
                record.isActive = false;
                _transferVotingUnits(account, address(0), 1);
                emit PlayerRegistrationExpired(account, expected, actual);
            }
        }
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

    function setMintingLocked(bool isLocked) onlyOwner public {
        mintingLocked = isLocked;
    }

    function setTransferLimitsDisabled(bool isDisabled) onlyOwner public {
        transferLimitsDisabled = isDisabled;
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
