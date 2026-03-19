// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Reentrancy Attack (Bug Bounty Practice)                      │
// │  Difficulty:   Easy — 1 hidden bug (100 pts + 50 bonus for PoC)            │
// │  Module:       Bug Bounty Challenges — Level 1                              │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title Challenge_SafeVault
/// @author Allan Robinson
/// @notice A "secure" ETH vault that has been audited internally and signed off.
///         Users deposit ETH and can withdraw their own balance at any time.
///
/// ╔══════════════════════════════════════════════════════════════╗
/// ║  BUG BOUNTY CHALLENGE — EASY (1 hidden bug, 100 points)     ║
/// ║  Read the contract carefully. Find the vulnerability.        ║
/// ║  Write a PoC exploit test for +50 bonus points.             ║
/// ║  Submit your findings to be scored.                         ║
/// ╚══════════════════════════════════════════════════════════════╝
contract Challenge_SafeVault {
    // ─── Events ────────────────────────────────────────────────────────────────

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // ─── State ─────────────────────────────────────────────────────────────────

    address public owner;
    mapping(address => uint256) public balances;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor() {
        owner = msg.sender;
    }

    // ─── Functions ─────────────────────────────────────────────────────────────

    /// @notice Deposit ETH into the vault.
    function deposit() external payable {
        require(msg.value > 0, "SafeVault: zero deposit");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Withdraw your deposited ETH.
