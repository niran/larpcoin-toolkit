// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ISwapRouter} from "../src/uniswap/ISwapRouter.sol";

import "../src/LarpcoinGameFactory.sol";
import {Larpcoin} from "../src/Larpcoin.sol";
import {GamePiece} from "../src/GamePiece.sol";
import {GamePieceGovernor} from "../src/GamePieceGovernor.sol";


interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

interface ISwapTest {
    function WETH9() external view returns (address);
}

abstract contract SwapsForLarpcoins is ISwapTest {
    ISwapRouter public swapRouter = ISwapRouter(0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E);

    function swapForLarpcoins(address larpcoin) internal {
        // Swap for some larpcoins to send to test players.
        ERC20 weth = ERC20(this.WETH9());
        IWETH(this.WETH9()).deposit{value: 10 ether}();
        weth.approve(address(swapRouter), 10 ether);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: this.WETH9(),
            tokenOut: larpcoin,
            fee: 3000,
            recipient: address(this),
            amountIn: 1 ether,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        swapRouter.exactInputSingle(params);
    }
}
