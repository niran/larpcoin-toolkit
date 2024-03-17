// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Larpcoin} from "../src/Larpcoin.sol";


contract LarpcoinSetup is Script {
    function setUp() public {}

    function run() public {
        string memory name = "Larpcoin";
        string memory symbol = "LARP";
        uint208 totalSupply = 1_000_000_000;

        vm.broadcast();
        new Larpcoin(name, symbol, totalSupply);
    }
}
