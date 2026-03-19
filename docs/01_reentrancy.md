# 01 — Reentrancy Attack

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## What Is Reentrancy?

A reentrancy attack occurs when an external contract **calls back into the victim contract** before the original function finishes executing — specifically before the victim's state has been updated.

It is one of the most famous Ethereum vulnerabilities. The DAO hack (2016) stole ~$60M via reentrancy.

---

## The Checks-Effects-Interactions (CEI) Pattern

Every function that touches money must follow this order:

1. **Checks** — validate all conditions (`require`, `revert`)
2. **Effects** — update all state variables
3. **Interactions** — make external calls (send ETH, call other contracts)

Violating CEI (doing Interaction before Effect) enables reentrancy.

---

## Vulnerable Code

```solidity
// ❌ VULNERABLE — Interaction before Effect
function withdraw() external {
    uint256 amount = balances[msg.sender];
    require(amount > 0, "nothing to withdraw");

    // INTERACTION first ← attacker's receive() re-enters here
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);

    // EFFECT last ← balance never zeroed before re-entry
    balances[msg.sender] = 0;
