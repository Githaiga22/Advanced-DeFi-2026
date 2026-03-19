// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Oracle Manipulation + Reentrancy + Flash Loan (Bug Bounty)   │
// │  Difficulty:   Hard — 3+ hidden bugs (325+ pts + 50 bonus each for PoC)   │
// │  Module:       Bug Bounty Challenges — Level 3                              │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title Challenge_DeFiPool
/// @author Allan Robinson
/// @notice A liquidity pool that allows users to:
///           - Provide liquidity (ETH + token) and receive LP shares
///           - Swap ETH for tokens using the pool price
///           - Borrow ETH against token collateral (priced by the pool)
///           - Flash-loan ETH (repaid in same tx with a 0.3% fee)
///
/// ╔══════════════════════════════════════════════════════════════╗
/// ║  BUG BOUNTY CHALLENGE — HARD (3+ bugs, 325+ points)         ║
/// ║  Bug 1: Critical ~100 pts   |  Bug 2: High ~75 pts          ║
/// ║  Bug 3: High ~75 pts        |  Bug 4: Medium ~50 pts (bonus)║
/// ║  Write PoC exploit tests for +50 bonus points per bug.      ║
/// ╚══════════════════════════════════════════════════════════════╝
contract Challenge_DeFiPool {
    // ─── Events ────────────────────────────────────────────────────────────────

    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount, uint256 shares);
    event Swapped(address indexed user, uint256 ethIn, uint256 tokensOut);
    event Borrowed(address indexed user, uint256 collateral, uint256 ethBorrowed);
    event FlashLoan(address indexed borrower, uint256 amount, uint256 fee);

    // ─── State ─────────────────────────────────────────────────────────────────

    address public owner;

    uint256 public ethReserve;
    uint256 public tokenReserve;
    uint256 public totalShares;

    mapping(address => uint256) public shares;
    mapping(address => uint256) public tokenCollateral;
    mapping(address => uint256) public ethDebt;
    mapping(address => uint256) public tokenBalances;

    bool private _flashLoanActive;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor() {
