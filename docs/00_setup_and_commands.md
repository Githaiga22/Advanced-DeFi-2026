# 00 — Setup & Essential Commands

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## Prerequisites

```bash
# Install Foundry (installs forge, cast, anvil, chisel)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify installation
forge --version
cast --version
anvil --version
```

---

## Project Setup

```bash
# Clone and install dependencies
git clone <repo-url>
cd basic-solc-project
forge install         # installs lib/forge-std (already done if cloned)

# Build all contracts
forge build

# Check contract sizes (fail on >24KB)
forge build --sizes
```

---

## Running Tests

```bash
# Run all tests
forge test

# Run with verbose output (show logs + traces on failure)
forge test -vvv

# Run with FULL traces (4 levels — shows every call, return, emit)
forge test -vvvv

# Run a specific test file
forge test --match-path test/03_exploits/ReentrancyExploit.t.sol -vvvv

# Run a specific test function
forge test --match-test test_ReentrancyDrainsBank -vvvv

# Run tests matching a pattern
forge test --match-contract ReentrancyExploit

# Run tests for a specific module
forge test --match-path "test/01_basics/*"
```

---

## Fuzz Testing

```bash
# Fuzz with default runs (set in foundry.toml: 1000)
forge test --match-test testFuzz_

# Fuzz with more runs (override for this session)
forge test --match-test testFuzz_ --fuzz-runs 10000

# Run CI profile (10 000 fuzz runs)
FOUNDRY_PROFILE=ci forge test
```

---

## Gas Analysis

```bash
# Show gas report for all functions
forge test --gas-report

