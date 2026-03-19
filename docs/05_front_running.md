# 05 — Front-Running & MEV (Maximal Extractable Value)

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## What Is Front-Running?

Ethereum transactions are publicly visible in the mempool before they are included in a block. A **front-runner** (often a MEV bot or miner/validator) sees your pending transaction, copies it with a higher gas price, and gets their version included first.

---

## Types of MEV Attacks

### 1. Classic Front-Running
A bot sees your `buy(token, 1000 USDC)` transaction and inserts an identical buy before yours, then sells after you — profiting from the price impact your trade causes.

### 2. Sandwich Attack
```
Block N:
  [MEV bot]  buy(token)   ← drives price up
  [Victim]   buy(token)   ← pays inflated price
  [MEV bot]  sell(token)  ← profits from victim's price impact
```

### 3. Back-Running
The MEV bot executes **after** a known profitable transaction — e.g., liquidating a position immediately after a price update.

### 4. Transaction Ordering (Reordering)
Validators can reorder transactions within their block to maximize MEV.

---

## Vulnerable Patterns

### Approve + TransferFrom (ERC-20 Race Condition)
