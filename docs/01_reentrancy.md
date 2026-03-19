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
}
```

---

## The Attack

```
1. Attacker.attack() calls VulnerableBank.deposit{value: 1 ETH}()
2. Attacker calls VulnerableBank.withdraw()
3. Bank sends 1 ETH → triggers Attacker.receive()
4. Attacker.receive() calls VulnerableBank.withdraw() AGAIN
5. Bank's balance check passes (balance still shows 1 ETH!)
6. Bank sends another 1 ETH → Attacker.receive() fires again
7. Loop continues until bank is drained
```

**Trace (run with -vvvv):**
```
[CALL] VulnerableBank.withdraw()
  [CALL] Attacker.receive() ← 1st re-entry
    [CALL] VulnerableBank.withdraw()
      [CALL] Attacker.receive() ← 2nd re-entry
        [CALL] VulnerableBank.withdraw()
          ...
```

---

## Fixed Code

```solidity
// ✅ FIXED — CEI pattern + mutex guard
bool private locked;

modifier nonReentrant() {
    require(!locked, "reentrant call");
    locked = true;
    _;
    locked = false;
}

function withdraw() external nonReentrant {
    uint256 amount = balances[msg.sender];
    require(amount > 0, "nothing to withdraw");

    // EFFECT first ← state zeroed before any external call
    balances[msg.sender] = 0;

    // INTERACTION last
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);
}
```

---

## Running the Exploit

```bash
# See the recursive call tree
forge test --match-path test/03_exploits/ReentrancyExploit.t.sol -vvvv
```

Look for the indented, repeating `VulnerableBank::withdraw()` calls in the trace.

---

## Real-World Examples

| Incident | Year | Loss |
|---|---|---|
| The DAO Hack | 2016 | ~$60M |
| Cream Finance | 2021 | $130M |
| Siren Protocol | 2021 | $3.5M |
| Ola Finance | 2022 | $3.6M |

---

## Key Takeaways

- Always follow CEI order: Checks → Effects → Interactions
- Use `nonReentrant` modifiers for any function that sends ETH
- Cross-function reentrancy is possible too (e.g., `deposit()` re-entered from `withdraw()`)
- OpenZeppelin's `ReentrancyGuard` is production-ready — use it after understanding this manual version
