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
