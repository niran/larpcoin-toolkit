// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";

import {Larpcoin} from "./Larpcoin.sol";
import {GamePiece} from "./GamePiece.sol";
import {LarpcoinGovernor} from "./LarpcoinGovernor.sol";
import {GamePieceGovernor} from "./GamePieceGovernor.sol";


contract LarpcoinFactory {
    function build(string memory larpcoinName, string memory larpcoinSymbol, uint208 totalSupply,
        string memory pieceName, string memory pieceSymbol, uint256 pieceCost, string memory  pieceTokenURI,
        uint256 timelockDelay)
        public
        returns (GamePiece, Larpcoin, TimelockController, TimelockController, GamePieceGovernor, LarpcoinGovernor)
    {
        Larpcoin larpcoin = new Larpcoin(larpcoinName, larpcoinSymbol, totalSupply);
        GamePiece piece = new GamePiece(pieceName, pieceSymbol, pieceCost, pieceTokenURI, address(this));
        address[] memory openRole = new address[](1);
        openRole[0] = address(0);
        
        TimelockController pHouse = new TimelockController(timelockDelay, new address[](0), openRole, address(this));
        GamePieceGovernor GamePieceGovernor = new GamePieceGovernor(piece, pHouse);
        pHouse.grantRole(pHouse.PROPOSER_ROLE(), address(GamePieceGovernor));
        pHouse.grantRole(pHouse.CANCELLER_ROLE(), address(GamePieceGovernor));
        pHouse.revokeRole(pHouse.DEFAULT_ADMIN_ROLE(), address(this));

        TimelockController fpHouse = new TimelockController(timelockDelay, new address[](0), openRole, address(this));
        LarpcoinGovernor larpcoinGovernor = new LarpcoinGovernor(larpcoin, fpHouse);
        fpHouse.grantRole(fpHouse.PROPOSER_ROLE(), address(larpcoinGovernor));
        fpHouse.grantRole(fpHouse.CANCELLER_ROLE(), address(larpcoinGovernor));
        fpHouse.revokeRole(fpHouse.DEFAULT_ADMIN_ROLE(), address(this));

        return (piece, larpcoin, pHouse, fpHouse, GamePieceGovernor, larpcoinGovernor);
    }
}
