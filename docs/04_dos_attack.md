# 04 — Denial of Service (DoS) Attacks

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## What Is a DoS Attack in Smart Contracts?

A DoS attack makes a contract's functions permanently uncallable (or very expensive to call) — without requiring the attacker to drain funds directly.

---

## Type 1: Push-Payment DoS

When a contract pushes ETH to an address, a malicious contract can cause the push to revert — blocking the entire operation.

### Vulnerable Code

```solidity
// ❌ VULNERABLE — push refund can be blocked
function bid() external payable {
    require(msg.value > highestBid, "bid too low");

    // Push refund to previous bidder — attacker can block this
    if (highestBidder != address(0)) {
        (bool success,) = highestBidder.call{value: highestBid}("");
        require(success, "refund failed"); // ← blocks if receiver reverts
    }

    highestBidder = msg.sender;
    highestBid = msg.value;
}
```

### The Attack

```solidity
contract AuctionBlocker {
    // receive() always reverts
    receive() external payable {
        revert("I reject refunds");
    }
