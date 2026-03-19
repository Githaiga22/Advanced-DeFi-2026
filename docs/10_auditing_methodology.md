# 10 — Smart Contract Auditing Methodology

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## Overview

A structured audit follows 5 phases. Skipping phases leads to missed vulnerabilities. Professional auditors at Cyfrin, Code4rena, and Sherlock follow variations of this process.

---

## Phase 1 — Reconnaissance

**Goal:** Understand what the protocol is supposed to do before looking for what it does wrong.

```
□ Read the README / whitepaper / documentation
□ Understand the protocol's economic model
□ Map all entry points (external/public functions)
□ Identify privileged roles (owner, admin, governance)
□ Note trusted vs untrusted contracts
□ List all assets at risk (ETH, ERC-20 tokens, NFTs)
□ Understand the intended invariants:
    "Total shares minted == sum of all deposits"
    "Only owner can call withdraw"
```

**Tools:** Browser, Notion, draw.io (for architecture diagrams)

---

## Phase 2 — Automated Analysis

**Goal:** Let tools find the low-hanging fruit quickly.

```bash
# Forge coverage — find untested code paths
forge coverage

# Slither — static analysis (150+ detectors)
pip3 install slither-analyzer
slither .

# Aderyn — Rust-based Solidity analyzer
cargo install aderyn
aderyn .

# Mythril — symbolic execution
pip3 install mythril
myth analyze src/MyContract.sol
```

**What automated tools find:**
- Reentrancy patterns
- Unchecked return values
- Integer overflow candidates
- Unused state variables
- Missing `emit` after state changes
- Shadowed state variables

**What they miss:**
- Business logic bugs
- Economic exploits
- Protocol-level design flaws

---

## Phase 3 — Manual Review Checklist

Work through every function systematically:

### Reentrancy
- [ ] Does the function make external calls?
- [ ] Is all state updated BEFORE external calls? (CEI pattern)
- [ ] Is there a reentrancy guard?

### Access Control
- [ ] Is `msg.sender` used (not `tx.origin`)?
- [ ] Are all privileged functions protected?
- [ ] Is ownership transfer two-step?
- [ ] Can `initialize()` be called twice?

### Integer Math
- [ ] Any `unchecked {}` blocks? Are they safe?
- [ ] Potential precision loss from division before multiplication?
- [ ] Correct token decimal scaling?

### Oracles
- [ ] Is the price from a spot source? (Can be manipulated)
- [ ] Is there a staleness check on Chainlink feeds?
- [ ] Are TWAP windows long enough?

### DoS
- [ ] Any unbounded loops over storage arrays?
- [ ] Any push-payments to arbitrary addresses?
- [ ] Can the contract be locked if one address reverts?

### Economic Logic
- [ ] Are the protocol's invariants preserved?
- [ ] Can someone profit by making the protocol perform worse?
- [ ] Flash loan attack surface?

### Front-Running
- [ ] Are there slippage parameters on DEX operations?
- [ ] Are there deadline parameters on time-sensitive operations?
- [ ] Should any function use a commit-reveal scheme?

---

## Phase 4 — Writing the Report

Use this format for each finding:

```markdown
## [H-01] Reentrancy in VulnerableBank.withdraw()

**Severity:** High
**Contract:** VulnerableBank.sol
**Function:** withdraw()

### Description
The `withdraw()` function makes an external ETH transfer via `call` BEFORE zeroing
the caller's balance. An attacker can deploy a contract with a malicious `receive()`
that re-enters `withdraw()` repeatedly, draining the bank.

### Proof of Concept
```forge test --match-test test_ReentrancyDrainsBank -vvvv```

See: test/03_exploits/ReentrancyExploit.t.sol

### Impact
All deposited ETH can be stolen in a single transaction. Legitimate users lose all funds.

### Recommended Fix
Apply the Checks-Effects-Interactions pattern: zero the balance BEFORE making the
external call. Optionally add a `nonReentrant` mutex modifier.

```solidity
function withdraw() external nonReentrant {
    uint256 amount = balances[msg.sender];
    require(amount > 0);
    balances[msg.sender] = 0;    // ← effect first
    (bool ok,) = msg.sender.call{value: amount}(""); // ← then interact
    require(ok);
}
```
```

### Severity Levels

| Severity | Definition |
|---|---|
| Critical | Funds can be stolen / contract destroyed |
| High | Significant loss of funds or protocol malfunction |
| Medium | Limited fund loss, access control issues |
| Low | Best practice violations, unlikely exploits |
| Informational | Style, gas, documentation |

---

## Phase 5 — Verification

After the developer implements fixes:

```bash
# 1. Re-run all tests — must still pass
forge test -vvv

# 2. Run the original exploit test — must now FAIL (exploit blocked)
forge test --match-path test/03_exploits/ReentrancyExploit.t.sol -vvvv

# 3. Run coverage again — ensure fix doesn't leave gaps
forge coverage

# 4. Re-run static analysis
slither .

# 5. Confirm the fix doesn't introduce new vulnerabilities
```

---

## Competitive Audit Platforms

| Platform | Format | Rewards |
|---|---|---|
| **CodeHawks** (Cyfrin) | Competitive + private | USDC prizes |
| **Code4rena** | Competitive (wardens) | USDC prizes |
| **Sherlock** | Competitive + judging | USDC prizes |
| **Immunefi** | Private bug bounty | Up to $10M |
| **HackerOne** | Bug bounty programs | Varies |

---

## Key Takeaways

- Reconnaissance before code — understand the *intent* first
- Automated tools are helpers, not replacements for manual review
- Write PoC exploit tests — they prove impact and confirm fixes
- A finding without a PoC is an unconfirmed theory
- Verification phase is as important as the discovery phase
