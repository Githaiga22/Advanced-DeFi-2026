// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Reentrancy Attack — CEI Pattern Violation                    │
// │  Vulnerability: Critical — Funds at Risk                                   │
// │  Module:       03 — Vulnerable Contracts                                   │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title VulnerableBank
/// @author Allan Robinson
/// @notice A simple ETH savings bank. Users deposit ETH and can withdraw it at any time.
/// @dev    WARNING (for auditors): This contract deliberately contains a reentrancy
///         vulnerability. It violates the Checks-Effects-Interactions (CEI) pattern —
///         the external call is made BEFORE the balance is updated.
///         See docs/01_reentrancy.md for the full explanation and fix.
contract VulnerableBank {
    // ─── Events ────────────────────────────────────────────────────────────────

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // ─── State ─────────────────────────────────────────────────────────────────

    mapping(address => uint256) public balances;

    // ─── External functions ────────────────────────────────────────────────────

    /// @notice Deposit ETH into the bank.
    function deposit() external payable {
        require(msg.value > 0, "VulnerableBank: zero deposit");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Withdraw your full balance.
