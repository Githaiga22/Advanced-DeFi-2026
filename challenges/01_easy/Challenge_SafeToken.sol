// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Access Control — Broken Ownership Transfer (Bug Bounty)      │
// │  Difficulty:   Easy — 1 hidden bug (75 pts + 50 bonus for PoC)             │
// │  Module:       Bug Bounty Challenges — Level 1                              │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title Challenge_SafeToken
/// @author Allan Robinson
/// @notice A production-ready ERC-20 token with minting controlled by the owner.
///         Passes all internal test suites.
///
/// ╔══════════════════════════════════════════════════════════════╗
/// ║  BUG BOUNTY CHALLENGE — EASY (1 hidden bug, 75 points)      ║
/// ║  Read the contract carefully. Find the vulnerability.        ║
/// ║  Write a PoC exploit test for +50 bonus points.             ║
/// ║  Submit your findings to be scored.                         ║
/// ╚══════════════════════════════════════════════════════════════╝
contract Challenge_SafeToken {
    // ─── Events ────────────────────────────────────────────────────────────────

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ─── State ─────────────────────────────────────────────────────────────────

    string public name = "SafeToken";
    string public symbol = "SAFE";
