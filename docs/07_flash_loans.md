# 07 — Flash Loans

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## What Is a Flash Loan?

A flash loan is an **uncollateralized loan that must be borrowed and repaid within a single transaction**. If the repayment fails, the entire transaction reverts — as if the loan never happened.

Flash loans are not inherently malicious. They are a DeFi primitive with legitimate uses. But attackers leverage them to manipulate markets at scale.

---

## How Flash Loans Work

```
Transaction starts:
  1. Borrow 1,000,000 USDC from Aave (no collateral needed)
  2. Use the 1M USDC to: arbitrage / manipulate / exploit
  3. Repay 1,000,000 USDC + 0.09% fee to Aave
Transaction ends:
  If repayment fails → everything reverts, attacker loses nothing
```

---

## Legitimate Uses

| Use Case | Description |
|---|---|
| Arbitrage | Buy low on DEX A, sell high on DEX B in one tx |
| Collateral swap | Change collateral type in a lending protocol |
| Self-liquidation | Repay own debt without pre-holding repayment token |
| Leveraged positions | Open leveraged trades without upfront capital |
