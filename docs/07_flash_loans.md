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

---

## Attack Uses

Flash loans amplify existing vulnerabilities. Common attack chains:

### Price Oracle Manipulation
```
1. Flash borrow 10,000 ETH
2. Dump ETH into AMM → crashes ETH price
3. Borrow against now-cheap ETH collateral (get more than fair value)
4. Repay flash loan
5. Keep the excess borrowed funds
```

### Governance Manipulation
```
1. Flash borrow 51% of governance tokens
2. Vote on malicious proposal (pass instantly)
3. Execute proposal (drain treasury)
4. Repay governance tokens
```

### Liquidation Attacks
```
1. Flash borrow the debt token
2. Liquidate a position for profit (collateral > debt)
3. Repay flash loan, keep collateral profit
```

---

## Protocol-Level Defenses

| Defense | How It Works |
|---|---|
| TWAP oracles | Price averaged over time — single-block manipulation has minimal effect |
| Governance time locks | Proposals can't execute immediately — flash loan votes become worthless |
| Snapshot-based voting | Voting weight locked at proposal creation block |
| Flash loan fees | Small fee makes large-scale attacks less profitable |
| Same-tx borrowing lock | Block the same address from borrowing and interacting in one tx |

---

## Flash Loan Providers

| Protocol | Chain | Fee |
|---|---|---|
| Aave v3 | Multi-chain | 0.05% |
| Uniswap v3 | Multi-chain | 0.05–1% |
| dYdX | Ethereum | 0% |
| Balancer | Multi-chain | 0% |

---

## Real-World Flash Loan Exploits

| Incident | Year | Loss | Attack Vector |
|---|---|---|---|
| bZx Attack | 2020 | $350K | Oracle manipulation |
| Harvest Finance | 2020 | $34M | Price manipulation |
| Cream Finance | 2021 | $130M | Reentrancy + flash loan |
| Mango Markets | 2022 | $117M | Oracle manipulation |
| Euler Finance | 2023 | $197M | Logic error + flash loan |

---

## Key Takeaways

- Flash loans don't create vulnerabilities — they **amplify existing ones**
- Any vulnerability that becomes worse with unlimited capital is flash-loan-exploitable
- TWAP oracles are the primary defense against price-based flash loan attacks
- Time locks on governance neutralize flash loan vote attacks
- Understanding flash loans is essential for advanced DeFi auditing
