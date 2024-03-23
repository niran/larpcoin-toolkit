// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";


contract TimelockControllerFactory {
    function openRole() internal pure returns (address[] memory) {
        address[] memory role = new address[](1);
        role[0] = address(0);
        return role;
    }

    function build(uint256 timelockDelay) public returns (TimelockController) {
        return new TimelockController(timelockDelay, new address[](0), openRole(), address(msg.sender));
    }
}
