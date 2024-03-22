// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Larpcoin} from "../src/Larpcoin.sol";
import {Slowlock} from "../src/Slowlock.sol";

contract SlowlockTest is Test {
    Larpcoin public larpcoin;
    Slowlock public slowlock;
    address public owner;
    address public recipient;

    function setUp() public {
        owner = address(bytes20(hex"10000000"));
        recipient = address(2);
        larpcoin = new Larpcoin("Larpcoin", "LARP", 1_000_000_000e18);
        
        // Set up a slowlock with a half-life of 1460 days (4 years)
        uint256[] memory decayFactorsX96 = new uint256[](32);
        decayFactorsX96[0] = 79228162078914441309719934688;
        decayFactorsX96[1] = 79228161643564547418094932367;
        decayFactorsX96[2] = 79228160772864766811441915127;
        decayFactorsX96[3] = 79228159031465234304523462198;
        decayFactorsX96[4] = 79228155548666284116233938090;
        decayFactorsX96[5] = 79228148583068843041820861280;
        decayFactorsX96[6] = 79228134651875798101470148507;
        decayFactorsX96[7] = 79228106789497057053162928428;
        decayFactorsX96[8] = 79228051064768970274064850710;
        decayFactorsX96[9] = 79227939615430377889450533232;
        decayFactorsX96[10] = 79227716717223517042681373586;
        decayFactorsX96[11] = 79227270922691084864054230083;
        decayFactorsX96[12] = 79226379341151329167291428200;
        decayFactorsX96[13] = 79224596208171857226675353705;
        decayFactorsX96[14] = 79221030062609909711338197416;
        decayFactorsX96[15] = 79213898253048709645592272659;
        decayFactorsX96[16] = 79199636559974782460104488323;
        decayFactorsX96[17] = 79171120876402637733399339858;
        decayFactorsX96[18] = 79114120306620099238407527035;
        decayFactorsX96[19] = 79000242253043198113616295780;
        decayFactorsX96[20] = 78772977663288196192260323272;
        decayFactorsX96[21] = 78320407958769867298286407057;
        decayFactorsX96[22] = 77423053976845087024027954998;
        decayFactorsX96[23] = 75659072441850980625774594763;
        decayFactorsX96[24] = 72250763631311596104176760411;
        decayFactorsX96[25] = 65887844418552707959198118407;
        decayFactorsX96[26] = 54793748893795318028937065452;
        decayFactorsX96[27] = 37895046692465547197822484357;
        decayFactorsX96[28] = 18125304415151601519199277294;
        decayFactorsX96[29] = 4146589416140577390039863934;
        decayFactorsX96[30] = 217021362611475288349078760;
        decayFactorsX96[31] = 594463765599281850667483;
        slowlock = new Slowlock(owner, recipient, address(larpcoin), decayFactorsX96);
    }

    function testDecayByHalf() public {
        larpcoin.transfer(address(slowlock), 500_000_000e18);
        vm.warp(block.timestamp + 365 days * 4);
        slowlock.stream();
        assertLt(larpcoin.balanceOf(address(slowlock)), 251_000_000e18);
        assertGt(larpcoin.balanceOf(recipient), 249_000_000e18);
    }

    function testDecayOneSecond() public {
        larpcoin.transfer(address(slowlock), 500_000_000e18);
        vm.warp(block.timestamp + 1);
        slowlock.stream();
        assertLt(larpcoin.balanceOf(address(slowlock)), 500_000_000e18);
        assertGt(larpcoin.balanceOf(recipient), 1e18);
        assertLt(larpcoin.balanceOf(recipient), 5e18);
    }

    function testDecayHalfLifeOneHourAtATime() public {
        larpcoin.transfer(address(slowlock), 500_000_000e18);
        uint256 halfLifeHours = 365 days * 4 / 1 hours;
        for (uint256 i = 0; i < halfLifeHours; i++) {
            vm.warp(block.timestamp + 1 hours);
            slowlock.stream();
        }

        assertLt(larpcoin.balanceOf(address(slowlock)), 251_000_000e18);
        assertGt(larpcoin.balanceOf(recipient), 249_000_000e18);
    }

    function testOwnerCanSetRecipient() public {
        address newRecipient = address(3);
        vm.prank(owner);
        slowlock.setRecipient(newRecipient);

        assertEq(slowlock.recipient(), newRecipient);
    }

    function testPublicCannotSetRecipient() public {
        address newRecipient = address(3);
        address hacker = address(5);
        vm.prank(hacker);
        vm.expectRevert();
        slowlock.setRecipient(newRecipient);
    }

    function testOwnerCanUnlock() public {
        vm.prank(owner);
        slowlock.unlock();

        assertEq(larpcoin.balanceOf(address(slowlock)), 0);
        assertEq(larpcoin.balanceOf(address(this)), 1_000_000_000e18);
    }

    function testPublicCannotUnlock() public {
        address hacker = address(5);
        vm.prank(hacker);
        vm.expectRevert();
        slowlock.unlock();
    }
}
