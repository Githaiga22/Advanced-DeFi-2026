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

```
Same transaction:
  Step 1: Flash borrow 10,000 ETH
  Step 2: Dump 10,000 ETH into AMM → reserves shift → ETH price drops, token price spikes
  Step 3: Call borrow() — AMM now shows 1 ETH = 0.0001 tokens (artificially)
          → borrower receives 10,000 ETH for 1 token of collateral
  Step 4: Repay flash loan
  Step 5: Keep stolen ETH
```

---

## Fix 1: Chainlink Price Feed

```solidity
// ✅ FIXED — Chainlink aggregator (off-chain, multi-source)
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

AggregatorV3Interface internal priceFeed =
    AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // ETH/USD mainnet

function getPrice() public view returns (uint256) {
    (, int256 price,,,) = priceFeed.latestRoundData();
    return uint256(price); // 8 decimals
}
```

---

## Fix 2: Uniswap v3 TWAP

```solidity
// ✅ FIXED — TWAP oracle (time-weighted average price)
function getTWAP(uint32 _period) public view returns (uint256) {
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = _period; // e.g. 1800 = 30 minutes ago
    secondsAgos[1] = 0;

    (int56[] memory tickCumulatives,) = pool.observe(secondsAgos);
    int56 tickDelta = tickCumulatives[1] - tickCumulatives[0];
    int24 avgTick = int24(tickDelta / int56(uint56(_period)));

    return TickMath.getSqrtRatioAtTick(avgTick);
}
```

---

## Checklist for Oracle Security

- [ ] Protocol does NOT use spot price from a single AMM
- [ ] TWAP window is long enough (≥30 minutes for low-liquidity pairs)
- [ ] Chainlink feeds have staleness checks (check `updatedAt`)
- [ ] Fallback oracle exists if primary fails
- [ ] Oracle manipulation is considered in economic attack modeling

---

## Staleness Check for Chainlink

```solidity
// ✅ Always check if the price is fresh
(, int256 price,, uint256 updatedAt,) = priceFeed.latestRoundData();
require(block.timestamp - updatedAt <= 3600, "Oracle: stale price");
require(price > 0, "Oracle: invalid price");
```

---

## Real-World Examples

| Incident | Year | Loss | Oracle Used |
|---|---|---|---|
| Harvest Finance | 2020 | $34M | Curve AMM spot price |
| Alpha Homora | 2021 | $37M | Homogeneous AMM spot |
| Mango Markets | 2022 | $117M | Self-referential spot price |
| Euler Finance | 2023 | $197M | Donation-inflated price |

---

## Key Takeaways

- Single-AMM spot prices can be moved with a flash loan in the same transaction
- TWAP prices are expensive to manipulate (requires sustained pressure over time)
- Chainlink is the production standard for price feeds in DeFi
- Always add staleness checks to Chainlink — it can stop updating during extreme events
