// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct GovernanceArgs {
    uint48 votingDelay;
    uint32 votingPeriod;
    uint256 proposalThreshold;
    uint256 timelockDelay;
}
