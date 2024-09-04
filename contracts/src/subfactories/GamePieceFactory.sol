// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {GamePiece} from "../GamePiece.sol";


struct GamePieceArgs {
    string name;
    string symbol;
    uint256 cost;
    uint256 roundLength;
    string tokenURI;
}

contract GamePieceFactory {
    function build(GamePieceArgs memory gpArgs, address larpcoin, address lcTimelock, address slowlock) public returns (GamePiece) {
        return new GamePiece(gpArgs.name, gpArgs.symbol, gpArgs.cost, larpcoin, slowlock, gpArgs.roundLength, gpArgs.tokenURI, lcTimelock);
    }
}
