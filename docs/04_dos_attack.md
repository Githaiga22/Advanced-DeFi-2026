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
}
```

Once `AuctionBlocker` becomes the highest bidder, **nobody can outbid them** — the refund push always fails.

### Fix: Pull-Payment Pattern

```solidity
// ✅ FIXED — pull payment
mapping(address => uint256) public pendingRefunds;

function bid() external payable {
    require(msg.value > highestBid, "bid too low");

    // Record the refund, don't push it
    if (highestBidder != address(0)) {
        pendingRefunds[highestBidder] += highestBid;
    }

    highestBidder = msg.sender;
    highestBid = msg.value;
}

function withdrawRefund() external {
    uint256 amount = pendingRefunds[msg.sender];
    require(amount > 0, "nothing to withdraw");
    pendingRefunds[msg.sender] = 0;
    (bool ok,) = msg.sender.call{value: amount}("");
    require(ok);
}
```

---

## Type 2: Unbounded Loop DoS

If a function iterates over an array that can grow without bound, an attacker can grow it until the loop exceeds the block gas limit.

### Vulnerable Code

```solidity
// ❌ VULNERABLE — allBidders grows with every bid
address[] public allBidders;
