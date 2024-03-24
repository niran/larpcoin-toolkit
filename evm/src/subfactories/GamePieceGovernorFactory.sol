// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";

import {TimelockControllerFactory} from "./TimelockControllerFactory.sol";
import {SlowlockFactory} from "./SlowlockFactory.sol";
import {GamePieceFactory, GamePieceArgs} from "./GamePieceFactory.sol";
import {GamePieceGovernor} from "../GamePieceGovernor.sol";
import {GamePiece} from "../GamePiece.sol";
import {Slowlock} from "../Slowlock.sol";
import {Larpcoin} from "../Larpcoin.sol";



struct GamePieceContracts {
    GamePiece piece;
    GamePieceGovernor gov;
    TimelockController timelock;
    Slowlock slowlock;
}

contract GamePieceGovernorFactory {
    TimelockControllerFactory tcFactory;
    SlowlockFactory slowlockFactory;
    GamePieceFactory gpFactory;


    constructor(address _tcFactory, address _slowlockFactory, address _gpFactory) {
        tcFactory = TimelockControllerFactory(_tcFactory);
        slowlockFactory = SlowlockFactory(_slowlockFactory);
        gpFactory = GamePieceFactory(_gpFactory);
    }

function build(GamePieceArgs memory gpArgs, uint256 timelockDelay, address larpcoin, address lcTimelock, uint256 halfLifeDays) public returns (GamePieceContracts memory) {
        GamePieceContracts memory gpc;
        gpc.timelock = tcFactory.build(timelockDelay);
        gpc.slowlock = slowlockFactory.build(lcTimelock, address(gpc.timelock), larpcoin, halfLifeDays);
        gpc.piece = gpFactory.build(gpArgs, larpcoin, lcTimelock, address(gpc.slowlock));
        
        gpc.gov = new GamePieceGovernor(gpc.piece, gpc.timelock);
        gpc.timelock.grantRole(gpc.timelock.PROPOSER_ROLE(), address(gpc.gov));
        gpc.timelock.grantRole(gpc.timelock.CANCELLER_ROLE(), address(gpc.gov));
        gpc.timelock.revokeRole(gpc.timelock.DEFAULT_ADMIN_ROLE(), address(this));

        return gpc;
    }
}
