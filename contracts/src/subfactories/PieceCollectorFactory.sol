// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../PieceCollector.sol";


struct PieceCollectorArgs {
    string name;
    string symbol;
    uint256 cost;
    uint256 roundLength;
    string tokenURI;
    ValuablePiece[] pieces;
}

contract PieceCollectorFactory {
    function build(PieceCollectorArgs memory pcArgs) public returns (PieceCollector) {
        return new PieceCollector(
            pcArgs.name, pcArgs.symbol, pcArgs.cost, pcArgs.roundLength, pcArgs.tokenURI,
            msg.sender, pcArgs.pieces);
    }
}
