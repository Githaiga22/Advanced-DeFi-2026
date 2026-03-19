# Smart Contract Security Auditing

> A structured, hands-on learning journey into smart contract security — from Solidity basics to professional-grade vulnerability research.

**Author:** Allan Robinson
**Started:** March 2026
**Stack:** Solidity `^0.8.13` · Foundry · Forge-Std

---

## About This Repo

I'm learning smart contract security auditing and documenting everything as I go. This repo is my public learning log — every contract I write, every vulnerability I study, and every exploit I implement lives here.

If you're on the same journey, feel free to follow along, use the code for your own learning, or reach out. The more people studying this stuff, the safer Web3 gets.

---

## What's Inside

### Learning Modules

```
src/
├── 01_basics/
│   ├── SimpleStorage.sol       — state variables, mappings, events, modifiers
│   └── FundMe.sol              — ETH handling, CEI pattern, pull payment
│
├── 02_intermediate/
│   ├── ERC20Token.sol          — ERC-20 from scratch (no OpenZeppelin)
│   └── SimpleVault.sol         — share-based accounting + manual reentrancy guard
│
└── 03_vulnerable/              — INTENTIONALLY BROKEN for auditing practice
    ├── VulnerableBank.sol      — Reentrancy attack
    ├── VulnerableToken.sol     — Integer overflow (unchecked{})
    ├── VulnerableAuction.sol   — DoS (push payment + unbounded loop)
    ├── VulnerableOracle.sol    — Price oracle manipulation
    ├── VulnerableLottery.sol   — Timestamp dependence
    └── VulnerableAccessControl.sol — tx.origin phishing + selfdestruct
```

### Exploit Tests

```
test/03_exploits/
├── ReentrancyExploit.t.sol   — drains VulnerableBank via recursive re-entry
├── OverflowExploit.t.sol     — mints unlimited tokens via unchecked underflow
└── DoSExploit.t.sol          — freezes VulnerableAuction with a reverting receiver
```

Run with full traces to see the attack happening in real time:

```bash
forge test --match-path test/03_exploits/ReentrancyExploit.t.sol -vvvv
```

### Bug Bounty Challenges

```
challenges/
├── 01_easy/     — 1 hidden bug each (100–150 pts)
├── 02_medium/   — 2 hidden bugs each (150–250 pts)
└── 03_hard/     — 3+ hidden bugs each (300–525 pts)
```

Each challenge contract looks like real production code. Find the bugs, write a report, and submit for scoring. See [`challenges/README.md`](challenges/README.md) for rules.

### Documentation

```
docs/
├── 00_setup_and_commands.md      — every forge / cast / anvil command you need
├── 01_reentrancy.md
├── 02_integer_overflow.md
├── 03_access_control.md
├── 04_dos_attack.md
├── 05_front_running.md
├── 06_timestamp_dependence.md
├── 07_flash_loans.md
├── 08_price_oracle_manipulation.md
├── 09_debugging_guide.md
├── 10_auditing_methodology.md
└── 11_cyfrin_updraft_resources.md
```

---

## Quick Start

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash && foundryup

# Clone and build
git clone <this-repo>
cd basic-solc-project
forge build

# Run all tests
forge test -vvv

# See a reentrancy attack live with full call traces
forge test --match-path test/03_exploits/ReentrancyExploit.t.sol -vvvv
```

---

## Vulnerability Coverage

