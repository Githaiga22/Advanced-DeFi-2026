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

# Save a gas snapshot (baseline for comparison)
forge snapshot

# Compare against snapshot (shows +/- gas changes)
forge snapshot --check
```

---

## Code Coverage

```bash
# Generate coverage report
forge coverage

# Generate LCOV report (for HTML viewing)
forge coverage --report lcov
genhtml lcov.info --output-dir coverage/
open coverage/index.html
```

---

## Formatting

```bash
# Format all Solidity files
forge fmt

# Check formatting without changing files (used in CI)
forge fmt --check
```

---

## Local Blockchain (Anvil)

```bash
# Start a local Ethereum node (forks mainnet state)
anvil

# Fork mainnet at a specific block
anvil --fork-url $MAINNET_RPC --fork-block-number 19000000

# Start with custom chain ID and block time
anvil --chain-id 31337 --block-time 12

# Pre-funded accounts are printed at startup
# Default private key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

---

## Deployment Scripts

```bash
# Dry-run (no broadcast — just simulate)
forge script script/Deploy.s.sol -vvvv

# Deploy to local Anvil
forge script script/Deploy.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  -vvvv

# Deploy to a testnet (e.g. Sepolia)
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_KEY \
  -vvvv
```

---

## Cast — Interacting with Contracts

```bash
# Call a read-only function
cast call <CONTRACT_ADDRESS> "balanceOf(address)(uint256)" <WALLET_ADDRESS> \
  --rpc-url http://localhost:8545

# Send a transaction
cast send <CONTRACT_ADDRESS> "deposit()" \
  --value 1ether \
