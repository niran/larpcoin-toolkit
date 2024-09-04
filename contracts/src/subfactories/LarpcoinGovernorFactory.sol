// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";

import {TimelockControllerFactory} from "./TimelockControllerFactory.sol";
import {GovernanceArgs} from "./GovernanceArgs.sol";
import {Larpcoin} from "../Larpcoin.sol";
import {LarpcoinGovernor} from "../LarpcoinGovernor.sol";


contract LarpcoinGovernorFactory {
    TimelockControllerFactory tcFactory;

    constructor(address _tcFactory) {
        tcFactory = TimelockControllerFactory(_tcFactory);
    }

    function openRole() internal pure returns (address[] memory) {
        address[] memory role = new address[](1);
        role[0] = address(0);
        return role;
    }

    function build(address larpcoin, GovernanceArgs memory govArgs) public returns (LarpcoinGovernor, TimelockController) {
        TimelockController timelock = tcFactory.build(govArgs.timelockDelay);
        LarpcoinGovernor gov = new LarpcoinGovernor(Larpcoin(larpcoin), timelock, govArgs.votingDelay, govArgs.votingPeriod, govArgs.proposalThreshold);
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(gov));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(gov));
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));

        return (gov, timelock);
    }
}
