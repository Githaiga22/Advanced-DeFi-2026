# 11 — Cyfrin Updraft & Learning Resources

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## This Repo + Cyfrin Updraft

This repository is a hands-on companion to the Cyfrin Updraft curriculum. Use both together:
- **Updraft** provides the lectures and theory
- **This repo** provides the practice contracts, exploit tests, and bug bounty challenges

---

## Cyfrin Updraft Course Alignment

### Foundry Fundamentals
Covers: `forge`, `cast`, `anvil`, deployment scripts, testing

| Updraft Module | This Repo |
|---|---|
| Solidity basics | `src/01_basics/SimpleStorage.sol` |
| Sending ETH | `src/01_basics/FundMe.sol` |
| Writing tests | `test/01_basics/` |
| Scripts | `script/Deploy.s.sol` |
| Commands | `docs/00_setup_and_commands.md` |

### Smart Contract Security (Core Curriculum)
Covers: vulnerability categories, auditing process, tools

| Updraft Module | This Repo |
|---|---|
| Reentrancy | `src/03_vulnerable/VulnerableBank.sol` + `docs/01_reentrancy.md` |
| Integer overflow | `src/03_vulnerable/VulnerableToken.sol` + `docs/02_integer_overflow.md` |
| Access control | `src/03_vulnerable/VulnerableAccessControl.sol` + `docs/03_access_control.md` |
| DoS attacks | `src/03_vulnerable/VulnerableAuction.sol` + `docs/04_dos_attack.md` |
| Front-running / MEV | `docs/05_front_running.md` |
| Timestamp dependence | `src/03_vulnerable/VulnerableLottery.sol` + `docs/06_timestamp_dependence.md` |
| Flash loans | `docs/07_flash_loans.md` |
| Oracle manipulation | `src/03_vulnerable/VulnerableOracle.sol` + `docs/08_price_oracle_manipulation.md` |
| Auditing methodology | `docs/10_auditing_methodology.md` |

### Advanced DeFi Security
Covers: complex protocols, MEV, cross-chain, governance

| Topic | This Repo |
|---|---|
| Liquidity pools | `challenges/03_hard/Challenge_DeFiPool.sol` |
| Governance attacks | `challenges/03_hard/Challenge_Governance.sol` |

---

## Recommended Learning Order

### Week 1 — Foundations
1. `docs/00_setup_and_commands.md` — master Foundry
2. `src/01_basics/SimpleStorage.sol` + test
3. `src/01_basics/FundMe.sol` + test
4. Run `forge test -vvv` — understand output

### Week 2 — Intermediate Solidity
1. `src/02_intermediate/ERC20Token.sol` + test
2. `src/02_intermediate/SimpleVault.sol` + test
3. Read `docs/01_reentrancy.md`

### Week 3 — Vulnerabilities
1. `src/03_vulnerable/VulnerableBank.sol`
2. Run `test/03_exploits/ReentrancyExploit.t.sol -vvvv`
3. `src/03_vulnerable/VulnerableToken.sol` + overflow exploit
4. `src/03_vulnerable/VulnerableAuction.sol` + DoS exploit

### Week 4 — Advanced Attacks
1. `src/03_vulnerable/VulnerableOracle.sol` + `docs/08_price_oracle_manipulation.md`
2. `src/03_vulnerable/VulnerableLottery.sol` + `docs/06_timestamp_dependence.md`
3. `src/03_vulnerable/VulnerableAccessControl.sol`

### Week 5+ — Bug Bounty Challenges
1. `challenges/01_easy/Challenge_SafeVault.sol`
2. `challenges/01_easy/Challenge_SafeToken.sol`
3. `challenges/02_medium/` — when scoring 80%+ on easy
4. `challenges/03_hard/` — when confident with medium

---

## Essential Tools

| Tool | Purpose | Link |
|---|---|---|
| Foundry | Build, test, deploy | foundry.paradigm.xyz |
| Slither | Static analysis | github.com/crytic/slither |
| Aderyn | Modern Solidity analyzer | github.com/cyfrin/aderyn |
| Chisel | Solidity REPL | Built into Foundry |
| Etherscan | Contract verification | etherscan.io |
| Tenderly | Transaction simulation | tenderly.co |

---

## Community & Bug Bounty Platforms

| Platform | What It Is |
|---|---|
| **CodeHawks** (Cyfrin) | Competitive audits + First Flight challenges for beginners |
| **Code4rena** | Competitive audits — warden system |
| **Sherlock** | Audits + insurance underwriting |
| **Immunefi** | Private bug bounties (up to $10M payouts) |
| **Cyfrin Discord** | Community support for Updraft students |

---

## Recommended Reading

| Resource | Why |
|---|---|
| "The Art of Smart Contract Security" | Foundational text |
| Ethereum Yellow Paper | Protocol internals |
| Trail of Bits Blog | Professional audit techniques |
| Rekt News | Real-world exploit postmortems |
| Solodit | Aggregated audit findings database |

---

## Patrick Collins Content

| Content | Platform |
|---|---|
| Foundry Full Course | YouTube — freeCodeCamp |
| Cyfrin Updraft | updraft.cyfrin.io |
| Smart Contract Security | Cyfrin Updraft |

---

> Start with CodeHawks "First Flight" — beginner-friendly competitive audits designed exactly for students at this level.
