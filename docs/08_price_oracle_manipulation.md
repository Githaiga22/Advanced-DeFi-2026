# 08 — Price Oracle Manipulation

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## What Is a Price Oracle?

A price oracle provides on-chain price data — for example, the price of ETH in USD. Lending protocols need this to calculate collateral values. DEXs need it to price assets.

The oracle is often the single point of failure for a DeFi protocol's economic security.

---

## Spot Price vs TWAP

| Oracle Type | How It Works | Manipulable? |
|---|---|---|
| **Spot price** (e.g. AMM current ratio) | Read at this exact moment | **Yes — single large trade** |
| **TWAP** (time-weighted avg) | Average over N blocks | Much harder (very expensive) |
| **Chainlink** (off-chain aggregator) | Multiple independent sources | Very hard |

---

## Vulnerable Code

```solidity
// ❌ VULNERABLE — spot price from a single AMM
function borrow(uint256 _tokenCollateral) external {
    // Read spot price from AMM THIS block — manipulable in same tx
    uint256 tokensPerETH = amm.getTokensPerETH();
    uint256 ethValue = (_tokenCollateral * 1e18) / tokensPerETH;

    // Send ETH based on the (potentially manipulated) price
    (bool ok,) = msg.sender.call{value: ethValue}("");
}
```

---

## The Attack (Spot Price Manipulation)
