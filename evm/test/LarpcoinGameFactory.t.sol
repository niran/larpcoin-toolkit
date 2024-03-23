// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ISwapRouter} from "../src/uniswap/ISwapRouter.sol";

import "../src/LarpcoinGameFactory.sol";
import {LarpcoinFactory, LarpcoinArgs} from "../src/subfactories/LarpcoinFactory.sol";
import {LarpcoinGovernorFactory} from "../src/subfactories/LarpcoinGovernorFactory.sol";
import {Larpcoin} from "../src/Larpcoin.sol";
import {GamePiece} from "../src/GamePiece.sol";
import {LarpcoinGovernor} from "../src/LarpcoinGovernor.sol";
import {GamePieceGovernor} from "../src/GamePieceGovernor.sol";

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

contract LarpcoinGameFactoryTest is Test {
    LarpcoinGameFactory public factory;
    ISwapRouter public swapRouter;
    address public WETH9 = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;

    function setUp() public {
        LarpcoinFactory lcFactory = new LarpcoinFactory(
            0x1238536071E1c677A632429e3655c799b22cDA52,
            0x0227628f3F023bb0B980b67D528571c95c6DaC1c,
            0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14
        );
        LarpcoinGovernorFactory lcGovFactory = new LarpcoinGovernorFactory();
        factory = new LarpcoinGameFactory(address(lcFactory), address(lcGovFactory));
        swapRouter = ISwapRouter(0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E);
    }

    function buildContracts() internal returns (LarpcoinContracts memory) {
        LarpcoinArgs memory lcArgs = LarpcoinArgs({
            name: "Larpcoin",
            symbol: "LARP",
            totalSupply: 1_000_000_000e18,
            liquiditySupply: 500_000_000e18,
            // Prices when larpcoin market cap is 10 ETH
            larpcoinSqrtPriceX96: 7922816251426434139029504,
            wethSqrtPriceX96: 792281625142643375935439503360000
        });
        GamePieceArgs memory gpArgs = GamePieceArgs({
            name: "GamePiece",
            symbol: "LGP",
            cost: 0.001e18,
            roundLength: 30 * 86400,
            tokenURI: "http://example.com"
        });
        return factory.build(lcArgs, gpArgs, 86400 /* 1 day */);
    }

    function testBuild() public {
        LarpcoinContracts memory c = buildContracts();

        assertEq(c.larpcoin.totalSupply(), 1_000_000_000e18);
        assertGe(c.larpcoin.balanceOf(address(c.slowlock)), 500_000_000e18);
        assertGe(c.larpcoin.balanceOf(address(c.pool)), 499_999_999e18);
        assertEq(c.piece.owner(), address(c.lcHouse));
        assertTrue(c.gpHouse.hasRole(c.gpHouse.PROPOSER_ROLE(), address(c.gpGov)));
        assertTrue(c.gpHouse.hasRole(c.gpHouse.CANCELLER_ROLE(), address(c.gpGov)));
        assertTrue(c.lcHouse.hasRole(c.lcHouse.PROPOSER_ROLE(), address(c.lcGov)));
        assertTrue(c.lcHouse.hasRole(c.lcHouse.CANCELLER_ROLE(), address(c.lcGov)));
    }

    function testCanSwapForLarpcoins() public {
        LarpcoinContracts memory c = buildContracts();
        ERC20 weth = ERC20(WETH9);
        address holder = address(1);
        vm.deal(holder, 1 ether);
        
        vm.startPrank(holder);
        IWETH(WETH9).deposit{value: 1 ether}();
        weth.approve(address(swapRouter), 1 ether);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH9,
            tokenOut: address(c.larpcoin),
            fee: 3000,
            recipient: address(holder),
            amountIn: 1 ether,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        swapRouter.exactInputSingle(params);
        vm.stopPrank();

        assertGe(c.larpcoin.balanceOf(holder), 80_000_000e18);
        assertLe(c.larpcoin.balanceOf(holder), 90_000_000e18);
        assertLe(weth.balanceOf(holder), 1e15);
    }
}
