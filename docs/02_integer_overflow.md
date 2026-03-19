# 02 — Integer Overflow & Underflow

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## What Is It?

Integer overflow/underflow occurs when arithmetic goes past the bounds of a fixed-size integer type:

- **Overflow:** `type(uint256).max + 1 = 0`
- **Underflow:** `uint256(0) - 1 = type(uint256).max`

Think of it like an odometer flipping from 99999 back to 00000.

---

## Solidity 0.8+ vs 0.7 and Below

| Version | Default Behavior |
|---|---|
| Solidity < 0.8 | Silently wraps (no revert) — **always dangerous** |
| Solidity ≥ 0.8 | Reverts on overflow/underflow **by default** |
| Solidity ≥ 0.8 with `unchecked {}` | **Wraps silently** — same as 0.7 |

**Key insight:** Modern optimised Solidity code often uses `unchecked {}` for gas savings. This is a real attack surface if used incorrectly — e.g., Solady, Uniswap v4.

---

## Vulnerable Code

