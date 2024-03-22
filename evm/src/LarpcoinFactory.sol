// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import {INonfungiblePositionManager} from "./uniswap/INonfungiblePositionManager.sol";
import {PoolInitializer} from "./uniswap/PoolInitializer.sol";
import {PeripheryImmutableState} from "./uniswap/PeripheryImmutableState.sol";
import {TickMath} from "./uniswap/TickMath.sol";

import {Larpcoin} from "./Larpcoin.sol";
import {GamePiece} from "./GamePiece.sol";
import {LarpcoinGovernor} from "./LarpcoinGovernor.sol";
import {GamePieceGovernor} from "./GamePieceGovernor.sol";

struct LarpcoinContracts {
    GamePiece piece;
    Larpcoin larpcoin;
    TimelockController gpHouse;
    GamePieceGovernor gpGov;
    TimelockController lcHouse;
    LarpcoinGovernor lcGov;
    IUniswapV3Pool pool;
}

struct LarpcoinArgs {
    string name;
    string symbol;
    uint208 totalSupply;
    uint208 liquiditySupply;
    uint160 wethSqrtPriceX96;
    uint160 larpcoinSqrtPriceX96;
    address remainderRecipient;
}

struct GamePieceArgs {
    string name;
    string symbol;
    uint256 cost;
    uint256 roundLength;
    string tokenURI;
}

struct PoolArgs {
    address token0;
    address token1;
    uint256 amount0;
    uint256 amount1;
    uint160 sqrtPriceX96;
    uint24 poolFee;
}

contract LarpcoinFactory is PoolInitializer {
    INonfungiblePositionManager public immutable positionManager;

    constructor(address positionManager_, address _factory, address _WETH9)
        PeripheryImmutableState(_factory, _WETH9)
    {
        positionManager = INonfungiblePositionManager(positionManager_);
    }

    function openRole() internal pure returns (address[] memory) {
        address[] memory role = new address[](1);
        role[0] = address(0);
        return role;
    }

    function createPool(LarpcoinContracts memory c, LarpcoinArgs memory lcArgs) public returns (IUniswapV3Pool, PoolArgs memory) {
        PoolArgs memory poolArgs = PoolArgs({
            token0: address(c.larpcoin),
            token1: WETH9,
            amount0: lcArgs.liquiditySupply,
            amount1: 0,
            sqrtPriceX96: lcArgs.larpcoinSqrtPriceX96,
            poolFee: 3000
        });
        
        if (poolArgs.token0 > poolArgs.token1) {
            poolArgs = PoolArgs({
                token0: poolArgs.token1,
                token1: poolArgs.token0,
                amount0: poolArgs.amount1,
                amount1: poolArgs.amount0,
                sqrtPriceX96: lcArgs.wethSqrtPriceX96,
                poolFee: poolArgs.poolFee
            });
        }

        address poolAddress = this.createAndInitializePoolIfNecessary(
            poolArgs.token0, poolArgs.token1, poolArgs.poolFee, poolArgs.sqrtPriceX96);
        return (IUniswapV3Pool(poolAddress), poolArgs);
    }

    function getMintParams(LarpcoinContracts memory c, LarpcoinArgs memory lcArgs, IUniswapV3Pool pool, PoolArgs memory poolArgs) public returns (INonfungiblePositionManager.MintParams memory) {
        (, int24 tick, , , , ,) = pool.slot0();
        int24 tickSpacing = pool.tickSpacing();

        int24 tickLower = (tick / tickSpacing + 1) * tickSpacing;
        int24 tickUpper = TickMath.MAX_TICK / tickSpacing * tickSpacing;
        if (poolArgs.token0 == WETH9) {
            tickUpper = (tick / tickSpacing) * tickSpacing;
            tickLower = TickMath.MIN_TICK + (TickMath.MIN_TICK % tickSpacing);
        }
        
        TransferHelper.safeApprove(address(c.larpcoin), address(positionManager), lcArgs.liquiditySupply);
        return INonfungiblePositionManager.MintParams({
            token0: poolArgs.token0,
            token1: poolArgs.token1,
            fee: poolArgs.poolFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: poolArgs.amount0,
            amount1Desired: poolArgs.amount1,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });
    }

    function initializeLiquidity(LarpcoinContracts memory c, LarpcoinArgs memory lcArgs) public returns (IUniswapV3Pool, uint256) {
        (IUniswapV3Pool pool, PoolArgs memory poolArgs) = createPool(c, lcArgs);
        INonfungiblePositionManager.MintParams memory params = getMintParams(c, lcArgs, pool, poolArgs);
        (, , uint256 amount0Actual, uint256 amount1Actual) = positionManager.mint(params);
        
        if (amount0Actual != 0) {
            return (pool, amount0Actual);
        }

        return (pool, amount1Actual);
    }

    function build(LarpcoinArgs memory lcArgs, GamePieceArgs memory gpArgs, uint256 timelockDelay)
        public
        returns (LarpcoinContracts memory)
    {
        LarpcoinContracts memory c;
        c.larpcoin = new Larpcoin(lcArgs.name, lcArgs.symbol, lcArgs.totalSupply);
        c.piece = new GamePiece(gpArgs.name, gpArgs.symbol, gpArgs.cost, address(c.larpcoin), gpArgs.roundLength, gpArgs.tokenURI, address(this));
        
        (IUniswapV3Pool pool, uint256 actualLarpcoinsInPool) = initializeLiquidity(c, lcArgs);
        c.pool = pool;
        // TODO: Transfer to Uniswap and the Slowlock instead of specifying a supply owner.
        c.larpcoin.transfer(address(lcArgs.remainderRecipient), lcArgs.totalSupply - actualLarpcoinsInPool);
        
        c.gpHouse = new TimelockController(timelockDelay, new address[](0), openRole(), address(this));
        c.gpGov = new GamePieceGovernor(c.piece, c.gpHouse);
        c.gpHouse.grantRole(c.gpHouse.PROPOSER_ROLE(), address(c.gpGov));
        c.gpHouse.grantRole(c.gpHouse.CANCELLER_ROLE(), address(c.gpGov));
        c.gpHouse.revokeRole(c.gpHouse.DEFAULT_ADMIN_ROLE(), address(this));

        c.lcHouse = new TimelockController(timelockDelay, new address[](0), openRole(), address(this));
        c.lcGov = new LarpcoinGovernor(c.larpcoin, c.lcHouse);
        c.lcHouse.grantRole(c.lcHouse.PROPOSER_ROLE(), address(c.lcGov));
        c.lcHouse.grantRole(c.lcHouse.CANCELLER_ROLE(), address(c.lcGov));
        c.lcHouse.revokeRole(c.lcHouse.DEFAULT_ADMIN_ROLE(), address(this));

        c.piece.transferOwnership(address(c.lcHouse));

        return c;
    }
}
