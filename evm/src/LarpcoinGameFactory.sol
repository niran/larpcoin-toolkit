// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import {LarpcoinFactory, LarpcoinArgs} from "./subfactories/LarpcoinFactory.sol";
import {LarpcoinGovernorFactory} from "./subfactories/LarpcoinGovernorFactory.sol";
import {GamePieceGovernorFactory, GamePieceArgs, GamePieceContracts} from "./subfactories/GamePieceGovernorFactory.sol";
import {GovernanceArgs} from "./subfactories/GovernanceArgs.sol";

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
    LarpcoinFactory public lcFactory;
    LarpcoinGovernorFactory public lcGovFactory;
    GamePieceGovernorFactory public gpGovFactory;

    constructor(address _lcFactory, address _lcGovFactory, address _gpGovFactory) {
        lcFactory = LarpcoinFactory(_lcFactory);
        lcGovFactory = LarpcoinGovernorFactory(_lcGovFactory);
        gpGovFactory = GamePieceGovernorFactory(_gpGovFactory);
    }

    function buildLarpcoin(LarpcoinContracts memory c, LarpcoinArgs memory lcArgs) internal returns (uint256) {
        (Larpcoin larpcoin, IUniswapV3Pool pool, uint256 actualLarpcoinsInPool) = lcFactory.build(lcArgs);
        c.larpcoin = larpcoin;
        c.pool = pool;
        return actualLarpcoinsInPool;
    }

    function buildLarpcoinGovernor(LarpcoinContracts memory c, GovernanceArgs memory lcGovArgs) internal {
        (LarpcoinGovernor lcGov, TimelockController lcTimelock) = lcGovFactory.build(address(c.larpcoin), lcGovArgs);
        c.lcGov = lcGov;
        c.lcTimelock = lcTimelock;
    }

    function buildGamePieceGovernor(LarpcoinContracts memory c, GamePieceArgs memory gpArgs, GovernanceArgs memory gpGovArgs, uint256 halfLifeDays) internal {
        GamePieceContracts memory gpc = gpGovFactory.build(gpArgs, gpGovArgs, address(c.larpcoin), address(c.lcTimelock), halfLifeDays);
        c.gpGov = gpc.gov;
        c.gpTimelock = gpc.timelock;
        c.slowlock = gpc.slowlock;
        c.piece = gpc.piece;
    }

    function build(LarpcoinArgs memory lcArgs, GamePieceArgs memory gpArgs, GovernanceArgs memory lcGovArgs, GovernanceArgs memory gpGovArgs, uint256 halfLifeDays)
        public
        returns (LarpcoinContracts memory)
    {
        LarpcoinContracts memory c;

        uint256 actualLarpcoinsInPool = buildLarpcoin(c, lcArgs);
        buildLarpcoinGovernor(c, lcGovArgs);
        buildGamePieceGovernor(c, gpArgs, gpGovArgs, halfLifeDays);

        c.larpcoin.transfer(address(c.slowlock), lcArgs.totalSupply - actualLarpcoinsInPool);

        return c;
    }
}
