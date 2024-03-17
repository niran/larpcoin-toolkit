// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";

import {Larpcoin} from "./Larpcoin.sol";
import {PlayerPiece} from "./PlayerPiece.sol";
import {LarpcoinGovernor} from "./LarpcoinGovernor.sol";
import {PlayerGovernor} from "./PlayerGovernor.sol";


contract LarpcoinFactory {
    function build(string memory larpcoinName, string memory larpcoinSymbol, uint208 totalSupply,
        string memory pieceName, string memory pieceSymbol, uint256 pieceCost, string memory  pieceTokenURI,
        uint256 timelockDelay)
        public
        returns (PlayerPiece, Larpcoin, TimelockController, TimelockController, PlayerGovernor, LarpcoinGovernor)
    {
        Larpcoin larpcoin = new Larpcoin(larpcoinName, larpcoinSymbol, totalSupply);
        PlayerPiece piece = new PlayerPiece(pieceName, pieceSymbol, pieceCost, pieceTokenURI, address(this));
        address[] memory openRole = new address[](1);
        openRole[0] = address(0);
        
        TimelockController pHouse = new TimelockController(timelockDelay, new address[](0), openRole, address(this));
        PlayerGovernor playerGovernor = new PlayerGovernor(piece, pHouse);
        pHouse.grantRole(pHouse.PROPOSER_ROLE(), address(playerGovernor));
        pHouse.grantRole(pHouse.CANCELLER_ROLE(), address(playerGovernor));
        pHouse.revokeRole(pHouse.DEFAULT_ADMIN_ROLE(), address(this));

        TimelockController fpHouse = new TimelockController(timelockDelay, new address[](0), openRole, address(this));
        LarpcoinGovernor larpcoinGovernor = new LarpcoinGovernor(larpcoin, fpHouse);
        fpHouse.grantRole(fpHouse.PROPOSER_ROLE(), address(larpcoinGovernor));
        fpHouse.grantRole(fpHouse.CANCELLER_ROLE(), address(larpcoinGovernor));
        fpHouse.revokeRole(fpHouse.DEFAULT_ADMIN_ROLE(), address(this));

        return (piece, larpcoin, pHouse, fpHouse, playerGovernor, larpcoinGovernor);
    }
}
