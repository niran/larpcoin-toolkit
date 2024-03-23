// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";

import {Larpcoin} from "../Larpcoin.sol";
import {LarpcoinGovernor} from "../LarpcoinGovernor.sol";


contract LarpcoinGovernorFactory {
    function openRole() internal pure returns (address[] memory) {
        address[] memory role = new address[](1);
        role[0] = address(0);
        return role;
    }

    function build(address larpcoin, uint256 timelockDelay) public returns (LarpcoinGovernor, TimelockController) {
        TimelockController timelock = new TimelockController(timelockDelay, new address[](0), openRole(), address(this));
        LarpcoinGovernor gov = new LarpcoinGovernor(Larpcoin(larpcoin), timelock);
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(gov));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(gov));
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));

        return (gov, timelock);
    }
}
