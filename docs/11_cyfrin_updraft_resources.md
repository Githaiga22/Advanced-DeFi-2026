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

