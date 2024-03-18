// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";

import {Larpcoin} from "./Larpcoin.sol";
import {GamePiece} from "./GamePiece.sol";
import {LarpcoinGovernor} from "./LarpcoinGovernor.sol";
import {GamePieceGovernor} from "./GamePieceGovernor.sol";

struct LarpcoinContracts {
    GamePiece piece;
    Larpcoin larpcoin;
    TimelockController gpHouse;
    GamePieceGovernor gpGov;
    TimelockController lcHouse;
    LarpcoinGovernor lcGov;
}

struct LarpcoinArgs{
    string name;
    string symbol;
    uint208 totalSupply;
    address supplyOwner;
}

struct GamePieceArgs {
    string name;
    string symbol;
    uint256 cost;
    string tokenURI;
}

contract LarpcoinFactory {
    function openRole() internal pure returns (address[] memory) {
        address[] memory role = new address[](1);
        role[0] = address(0);
        return role;
    }

    function build(LarpcoinArgs memory lcArgs, GamePieceArgs memory gpArgs, uint256 timelockDelay)
        public
        returns (LarpcoinContracts memory)
    {
        LarpcoinContracts memory c;
        c.larpcoin = new Larpcoin(lcArgs.name, lcArgs.symbol, lcArgs.totalSupply);
        // TODO: Transfer to Uniswap and the Slowlock instead of specifying a supply owner.
        c.larpcoin.transfer(address(lcArgs.supplyOwner), lcArgs.totalSupply);
        c.piece = new GamePiece(gpArgs.name, gpArgs.symbol, gpArgs.cost, gpArgs.tokenURI, address(this));
        
        c.gpHouse = new TimelockController(timelockDelay, new address[](0), openRole(), address(this));
        c.gpGov = new GamePieceGovernor(c.piece, c.gpHouse);
        c.gpHouse.grantRole(c.gpHouse.PROPOSER_ROLE(), address(c.gpGov));
        c.gpHouse.grantRole(c.gpHouse.CANCELLER_ROLE(), address(c.gpGov));
        c.gpHouse.revokeRole(c.gpHouse.DEFAULT_ADMIN_ROLE(), address(this));

        c.lcHouse = new TimelockController(timelockDelay, new address[](0), openRole(), address(this));
        c.lcGov = new LarpcoinGovernor(c.larpcoin, c.lcHouse);
        c.lcHouse.grantRole(c.lcHouse.PROPOSER_ROLE(), address(c.lcGov));
        c.lcHouse.grantRole(c.lcHouse.CANCELLER_ROLE(), address(c.lcGov));
        c.lcHouse.revokeRole(c.lcHouse.DEFAULT_ADMIN_ROLE(), address(this));

        c.piece.transferOwnership(address(c.lcHouse));

        return c;
    }
}
