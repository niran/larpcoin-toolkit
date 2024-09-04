// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Slowlock} from "../Slowlock.sol";


contract SlowlockFactory {
    function buildOneYearHalfLife(address owner, address recipient, address larpcoin) public returns (Slowlock) {
        // Set up a slowlock with a half-life of 365 days
        uint256[] memory decayFactorsX96 = new uint256[](32);
        decayFactorsX96[0] = 79228160772864766811441915127;
        decayFactorsX96[1] = 79228159031465234304523462198;
        decayFactorsX96[2] = 79228155548666284116233938090;
        decayFactorsX96[3] = 79228148583068843041820861280;
        decayFactorsX96[4] = 79228134651875798101470148507;
        decayFactorsX96[5] = 79228106789497057053162928428;
        decayFactorsX96[6] = 79228051064768970274064850710;
        decayFactorsX96[7] = 79227939615430377889450533232;
        decayFactorsX96[8] = 79227716717223517042681373586;
        decayFactorsX96[9] = 79227270922691084864054230083;
        decayFactorsX96[10] = 79226379341151329167291428200;
        decayFactorsX96[11] = 79224596208171857226675353705;
        decayFactorsX96[12] = 79221030062609909711338197416;
        decayFactorsX96[13] = 79213898253048709645592272659;
        decayFactorsX96[14] = 79199636559974782460104488323;
        decayFactorsX96[15] = 79171120876402637733399339858;
        decayFactorsX96[16] = 79114120306620099238407527035;
        decayFactorsX96[17] = 79000242253043198113616295780;
        decayFactorsX96[18] = 78772977663288196192260323272;
        decayFactorsX96[19] = 78320407958769867298286407057;
        decayFactorsX96[20] = 77423053976845087024027954998;
        decayFactorsX96[21] = 75659072441850980625774594763;
        decayFactorsX96[22] = 72250763631311596104176760411;
        decayFactorsX96[23] = 65887844418552707959198118407;
        decayFactorsX96[24] = 54793748893795318028937065452;
        decayFactorsX96[25] = 37895046692465547197822484357;
        decayFactorsX96[26] = 18125304415151601519199277294;
        decayFactorsX96[27] = 4146589416140577390039863934;
        decayFactorsX96[28] = 217021362611475288349078760;
        decayFactorsX96[29] = 594463765599281850667483;
        decayFactorsX96[30] = 4460373147576830997;
        decayFactorsX96[31] = 251109302;
        return new Slowlock(owner, recipient, larpcoin, decayFactorsX96);
    }

    function buildFourYearHalfLife(address owner, address recipient, address larpcoin) public returns (Slowlock) {
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
        return new Slowlock(owner, recipient, larpcoin, decayFactorsX96);
    }

    function build(address owner, address recipient, address larpcoin, uint256 halfLifeDays) public returns (Slowlock) {
        if (halfLifeDays == 1460) {
            return buildFourYearHalfLife(owner, recipient, larpcoin);
        } else if (halfLifeDays == 365) {
            return buildOneYearHalfLife(owner, recipient, larpcoin);
        } else {
            revert("Unsupported half-life for this factory. Deploy a new factory for other half-lives.");
        }
    }
}
