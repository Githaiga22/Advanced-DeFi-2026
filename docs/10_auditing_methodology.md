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
