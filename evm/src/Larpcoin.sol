// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";


contract Larpcoin is ERC20Votes {
    constructor(string memory name, string memory symbol, uint256 totalSupply)
        ERC20(name, symbol) EIP712("Larpcoin", "1")
    {
        _mint(msg.sender, totalSupply);
    }
}
