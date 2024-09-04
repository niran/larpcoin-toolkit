pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Slowlock is Ownable {
    address public recipient;
    address public token;
    uint256 public lastStreamTime;
    uint256[] public decayFactorsX96;
    uint256 public constant Q96 = 2**96;

    error DecayTimeMustBeInFuture(uint256 lastStreamTime, uint256 requestedTime);
    event Streamed(uint256 amount, uint256 duration, address indexed token);

    constructor(address owner_, address recipient_, address token_, uint256[] memory decayFactorsX96_) Ownable(owner_) {
        recipient = recipient_;
        token = token_;
        decayFactorsX96 = decayFactorsX96_;
        lastStreamTime = block.timestamp;
    }

    function stream() public {
        (uint256 targetBalance, uint256 currentBalance, uint256 usedDuration) = decayedBalanceAt(block.timestamp);
        uint256 streamedAmount = currentBalance - targetBalance;
        ERC20(token).transfer(recipient, streamedAmount);
        lastStreamTime += usedDuration;
        emit Streamed(streamedAmount, usedDuration, token);
    }

    function calculateDecay(uint256 duration) public view returns (uint256 decayX96, uint256 usedDuration) {
        decayX96 = Q96;
        usedDuration = 0;
        uint256 durationBits = duration;

        for (uint256 i = 0; i < decayFactorsX96.length; i++) {
            uint256 bit = durationBits % 2;
            durationBits >>= 1;

            if (bit == 1 && decayFactorsX96[i] != 0) {
                decayX96 = decayX96 * decayFactorsX96[i] / Q96;
                usedDuration += 2**i;
            }

            if (durationBits == 0) {
                break;
            }
        }
    }

    function decayedBalanceAt(uint256 time) public view returns (uint256, uint256, uint256) {
        if (time < lastStreamTime) {
            revert DecayTimeMustBeInFuture(lastStreamTime, time);
        }

        uint256 duration = time - lastStreamTime;
        (uint256 decayFactorX96, uint256 usedDuration) = calculateDecay(duration);
        uint256 currentBalance = ERC20(token).balanceOf(address(this));
        uint256 targetBalance = currentBalance * decayFactorX96 / Q96;
        return (targetBalance, currentBalance, usedDuration);
    }

    function setRecipient(address recipient_) public onlyOwner {
        recipient = recipient_;
    }

    function unlock() public onlyOwner {
        ERC20(token).transfer(owner(), ERC20(token).balanceOf(address(this)));
    }
}
