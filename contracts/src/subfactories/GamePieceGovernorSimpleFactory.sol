// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";


import {TimelockControllerFactory} from "./TimelockControllerFactory.sol";
import {GovernanceArgs} from "./GovernanceArgs.sol";
import {GamePieceGovernor} from "../GamePieceGovernor.sol";



contract GamePieceGovernorSimpleFactory {
    TimelockControllerFactory tcFactory;

    constructor(address _tcFactory) {
        tcFactory = TimelockControllerFactory(_tcFactory);
    }

    function buildSimple(IVotes nft, GovernanceArgs memory govArgs) public returns (GamePieceGovernor, TimelockController) {
        TimelockController timelock = tcFactory.build(govArgs.timelockDelay);
        GamePieceGovernor gov = new GamePieceGovernor(nft, timelock, govArgs.votingDelay, govArgs.votingPeriod, govArgs.proposalThreshold);
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(gov));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(gov));
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));

        return (gov, timelock);
    }
}
