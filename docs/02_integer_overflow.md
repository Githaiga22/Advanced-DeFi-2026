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

```solidity
// ❌ VULNERABLE — unchecked disables overflow protection
function burn(uint256 _amount) external {
    unchecked {
        balanceOf[msg.sender] -= _amount; // wraps on underflow!
        totalSupply -= _amount;
    }
}
```

Attack:
```solidity
// Attacker has 0 tokens, calls burn(1)
// unchecked: 0 - 1 = type(uint256).max = 115792...
attacker.burn(1);
// attacker now has 115 octillion tokens
```

---

## Safe Patterns

```solidity
// ✅ Option 1: Let Solidity 0.8 check for you (no unchecked)
function burn(uint256 _amount) external {
    balanceOf[msg.sender] -= _amount; // reverts if underflow
    totalSupply -= _amount;
}

// ✅ Option 2: Explicit check before unchecked (gas efficient + safe)
function burn(uint256 _amount) external {
    require(balanceOf[msg.sender] >= _amount, "insufficient balance");
    unchecked {
        balanceOf[msg.sender] -= _amount; // safe — checked above
        totalSupply -= _amount;
    }
}
```

---

## Running the Exploit

```bash
forge test --match-path test/03_exploits/OverflowExploit.t.sol -vvvv
```

---

## Historical Examples

| Incident | Year | Loss |
|---|---|---|
| BEC Token | 2018 | $900M market cap destroyed |
| BatchOverflow | 2018 | Multiple ERC-20 tokens |
| PAID Network | 2021 | $160M (private key + overflow) |

---

## Key Takeaways

- Default Solidity 0.8 protects you — don't fight it for "gas savings" on sensitive arithmetic
- `unchecked {}` is safe ONLY when you've mathematically proven no overflow is possible
- Always check external contracts' Solidity version — pre-0.8 code needs explicit SafeMath or manual guards
- When auditing: search for `unchecked`, `assembly`, and hand-rolled arithmetic
