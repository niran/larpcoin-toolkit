// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";

import {Larpcoin} from "../src/Larpcoin.sol";
import {PlayerPiece} from "../src/PlayerPiece.sol";
import {LarpcoinGovernor} from "../src/LarpcoinGovernor.sol";
import {PlayerGovernor} from "../src/PlayerGovernor.sol";


contract LarpcoinSetup is Script {
    function setUp() public {}

    function run() public {
        string memory name = "Larpcoin";
        string memory symbol = "LARP";
        uint208 totalSupply = 1_000_000_000;

        vm.startBroadcast();
        (, address msgSender,) = vm.readCallers();
        Larpcoin larpcoin = new Larpcoin(name, symbol, totalSupply);
        PlayerPiece piece = new PlayerPiece("PlayerPiece", "LPP", 0.001 ether, "http://example.com", msgSender);
        address[] memory openRole = new address[](1);
        openRole[0] = address(0);
        
        TimelockController houseOfPlayers = new TimelockController(7200 /* 1 day */, new address[](0), openRole, msgSender);
        PlayerGovernor playerGovernor = new PlayerGovernor(piece, houseOfPlayers);
        houseOfPlayers.grantRole(houseOfPlayers.PROPOSER_ROLE(), address(playerGovernor));
        houseOfPlayers.grantRole(houseOfPlayers.CANCELLER_ROLE(), address(playerGovernor));
        houseOfPlayers.revokeRole(houseOfPlayers.DEFAULT_ADMIN_ROLE(), msgSender);

        TimelockController houseOfFuturePlayers = new TimelockController(7200 /* 1 day */, new address[](0), openRole, msgSender);
        LarpcoinGovernor larpcoinGovernor = new LarpcoinGovernor(larpcoin, houseOfFuturePlayers);
        houseOfFuturePlayers.grantRole(houseOfFuturePlayers.PROPOSER_ROLE(), address(larpcoinGovernor));
        houseOfFuturePlayers.grantRole(houseOfFuturePlayers.CANCELLER_ROLE(), address(larpcoinGovernor));
        houseOfFuturePlayers.revokeRole(houseOfFuturePlayers.DEFAULT_ADMIN_ROLE(), msgSender);
        vm.stopBroadcast();
    }
}
