// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import {INonfungiblePositionManager} from "../uniswap/INonfungiblePositionManager.sol";
import {PoolInitializer} from "../uniswap/PoolInitializer.sol";
import {PeripheryImmutableState} from "../uniswap/PeripheryImmutableState.sol";
import {TickMath} from "../uniswap/TickMath.sol";

import {Larpcoin} from "../Larpcoin.sol";


struct LarpcoinArgs {
    string name;
    string symbol;
    uint208 totalSupply;
    uint208 liquiditySupply;
    address liquidityDestination;
    uint160 wethSqrtPriceX96;
    uint160 larpcoinSqrtPriceX96;
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

    function createPool(address larpcoin, LarpcoinArgs memory lcArgs) public returns (IUniswapV3Pool, PoolArgs memory) {
        PoolArgs memory poolArgs = PoolArgs({
            token0: larpcoin,
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

    function getMintParams(address larpcoin, LarpcoinArgs memory lcArgs, IUniswapV3Pool pool, PoolArgs memory poolArgs) public returns (INonfungiblePositionManager.MintParams memory) {
        (, int24 tick, , , , ,) = pool.slot0();
        int24 tickSpacing = pool.tickSpacing();

        int24 tickLower = (tick / tickSpacing + 1) * tickSpacing;
        int24 tickUpper = TickMath.MAX_TICK / tickSpacing * tickSpacing;
        if (poolArgs.token0 == WETH9) {
            tickUpper = (tick / tickSpacing) * tickSpacing;
            tickLower = TickMath.MIN_TICK + (TickMath.MIN_TICK % tickSpacing);
        }
        
        TransferHelper.safeApprove(larpcoin, address(positionManager), lcArgs.liquiditySupply);
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
            recipient: lcArgs.liquidityDestination,
            deadline: block.timestamp
        });
    }

    function initializeLiquidity(address larpcoin, LarpcoinArgs memory lcArgs) public returns (IUniswapV3Pool, uint256, uint256) {
        (IUniswapV3Pool pool, PoolArgs memory poolArgs) = createPool(larpcoin, lcArgs);
        INonfungiblePositionManager.MintParams memory params = getMintParams(larpcoin, lcArgs, pool, poolArgs);
        (uint256 tokenId, , uint256 amount0Actual, uint256 amount1Actual) = positionManager.mint(params);
        
        if (amount0Actual != 0) {
            return (pool, amount0Actual, tokenId);
        }

        return (pool, amount1Actual, tokenId);
    }

    function build(LarpcoinArgs memory lcArgs) public returns (Larpcoin, IUniswapV3Pool, uint256) {
        Larpcoin larpcoin = new Larpcoin(lcArgs.name, lcArgs.symbol, lcArgs.totalSupply);
        (IUniswapV3Pool pool, uint256 actualLarpcoinsInPool, uint256 tokenId) = initializeLiquidity(address(larpcoin), lcArgs);
        larpcoin.transfer(msg.sender, lcArgs.totalSupply - actualLarpcoinsInPool);
        return (larpcoin, pool, actualLarpcoinsInPool);
    }
}
