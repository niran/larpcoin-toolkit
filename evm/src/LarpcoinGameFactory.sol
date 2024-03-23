// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import {LarpcoinFactory, LarpcoinArgs} from "./subfactories/LarpcoinFactory.sol";
import {LarpcoinGovernorFactory} from "./subfactories/LarpcoinGovernorFactory.sol";
import {GamePieceGovernorFactory, GamePieceArgs, GamePieceContracts} from "./subfactories/GamePieceGovernorFactory.sol";

import {Larpcoin} from "./Larpcoin.sol";
import {Slowlock} from "./Slowlock.sol";
import {GamePiece} from "./GamePiece.sol";
import {LarpcoinGovernor} from "./LarpcoinGovernor.sol";
import {GamePieceGovernor} from "./GamePieceGovernor.sol";


struct LarpcoinContracts {
    GamePiece piece;
    Larpcoin larpcoin;
    Slowlock slowlock;
    TimelockController gpTimelock;
    GamePieceGovernor gpGov;
    TimelockController lcTimelock;
    LarpcoinGovernor lcGov;
    IUniswapV3Pool pool;
}

contract LarpcoinGameFactory {
    LarpcoinFactory lcFactory;
    LarpcoinGovernorFactory lcGovFactory;
    GamePieceGovernorFactory gpGovFactory;

    constructor(address _lcFactory, address _lcGovFactory, address _gpGovFactory) {
        lcFactory = LarpcoinFactory(_lcFactory);
        lcGovFactory = LarpcoinGovernorFactory(_lcGovFactory);
        gpGovFactory = GamePieceGovernorFactory(_gpGovFactory);
    }

    function build(LarpcoinArgs memory lcArgs, GamePieceArgs memory gpArgs, uint256 timelockDelay)
        public
        returns (LarpcoinContracts memory)
    {
        LarpcoinContracts memory c;
  
        (Larpcoin larpcoin, IUniswapV3Pool pool, uint256 actualLarpcoinsInPool) = lcFactory.build(lcArgs);
        c.larpcoin = larpcoin;
        c.pool = pool;
         
        (LarpcoinGovernor lcGov, TimelockController lcTimelock) = lcGovFactory.build(address(larpcoin), timelockDelay);
        c.lcGov = lcGov;
        c.lcTimelock = lcTimelock;

        GamePieceContracts memory gpc = gpGovFactory.build(gpArgs, timelockDelay, address(larpcoin), address(lcTimelock));

        c.gpGov = gpc.gov;
        c.gpTimelock = gpc.timelock;
        c.slowlock = gpc.slowlock;
        c.piece = gpc.piece;

        larpcoin.transfer(address(c.slowlock), lcArgs.totalSupply - actualLarpcoinsInPool);

        return c;
    }
}
