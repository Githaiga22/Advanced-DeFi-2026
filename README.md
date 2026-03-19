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

| # | Vulnerability | Contract | Exploit Test | Doc |
|---|---|---|---|---|
| 1 | Reentrancy | `VulnerableBank.sol` | `ReentrancyExploit.t.sol` | `01_reentrancy.md` |
| 2 | Integer Overflow | `VulnerableToken.sol` | `OverflowExploit.t.sol` | `02_integer_overflow.md` |
| 3 | Access Control | `VulnerableAccessControl.sol` | — | `03_access_control.md` |
| 4 | DoS Attack | `VulnerableAuction.sol` | `DoSExploit.t.sol` | `04_dos_attack.md` |
| 5 | Front-Running / MEV | — | — | `05_front_running.md` |
| 6 | Timestamp Dependence | `VulnerableLottery.sol` | — | `06_timestamp_dependence.md` |
| 7 | Flash Loans | — | — | `07_flash_loans.md` |
| 8 | Oracle Manipulation | `VulnerableOracle.sol` | — | `08_price_oracle_manipulation.md` |

---

## Follow the Journey

This repo grows as I learn. I'm working through:

- **Cyfrin Updraft** — Foundry Fundamentals + Smart Contract Security
- **CodeHawks First Flight** — beginner-friendly competitive audits
- **Immunefi / Code4rena / Sherlock** — the goal

If you're studying smart contract security too — follow along, open an issue, or just say hello. There's strength in learning together.

---

## Useful Commands

```bash
forge build --sizes         # compile + show contract sizes
forge test -vvv             # run all tests
forge test -vvvv            # full call traces (use for exploits)
forge coverage              # code coverage report
forge snapshot              # save gas snapshot
forge fmt                   # format all Solidity files
anvil                       # local Ethereum node
cast call <addr> "fn()"     # read a contract function
```

---

## Project Structure

```
basic-solc-project/
├── src/                    — learning contracts (01 basics → 03 vulnerable)
├── test/                   — test suite (unit + exploit tests)
├── script/                 — deployment scripts
├── challenges/             — bug bounty practice challenges
├── docs/                   — vulnerability guides + cheatsheets
├── lib/                    — forge-std (submodule)
├── foundry.toml            — project config (fuzz: 1000 runs)
└── .gitignore
```

---

*Built with Foundry. Learning in public.*
