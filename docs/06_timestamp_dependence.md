# 06 — Timestamp Dependence & Weak Randomness

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## The Problem with block.timestamp

`block.timestamp` is set by the block proposer (validator). Post-Merge (PoS Ethereum), validators:
- Have a ~15-second window of flexibility when setting the timestamp
- Can try multiple timestamp values and only publish the block if it benefits them
- Have complete knowledge of the block's contents before publishing

This makes `block.timestamp` **unsuitable for randomness** and risky for strict timing requirements.

---

## Vulnerable Randomness

```solidity
// ❌ VULNERABLE — predictable and manipulable
function drawWinner() external {
    uint256 randomIndex = uint256(
        keccak256(abi.encodePacked(
            block.timestamp,   // ← validator controls this
            block.prevrandao,  // ← partially controllable post-merge
            players.length
        ))
    ) % players.length;

    address winner = players[randomIndex];
    ...
}
```

### The Attack
1. Validator buys a lottery ticket
2. Waits until scheduled to propose a block
3. Tries different `timestamp` values in simulation
4. Publishes only the block where they win

---

## Vulnerable Timing

```solidity
// ❌ Risky for time-critical checks (±15 seconds)
require(block.timestamp >= saleStartTime, "not started");
require(block.timestamp <= saleEndTime, "ended");
```

For short time windows (minutes), a validator can shift the timestamp to participate in an exclusive window they shouldn't be in.

---

## Fixes

### For Randomness: Chainlink VRF

```solidity
// ✅ FIXED — Chainlink VRF for cryptographically secure randomness
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract SecureLottery is VRFConsumerBaseV2 {
    // Request random words from Chainlink oracle
    function requestWinner() external {
        vrfCoordinator.requestRandomWords(
            keyHash, subscriptionId, requestConfirmations, callbackGasLimit, numWords
        );
    }

    // Chainlink calls back with provably random value
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 winnerIndex = randomWords[0] % players.length;
        winner = players[winnerIndex];
    }
