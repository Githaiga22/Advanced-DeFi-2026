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
