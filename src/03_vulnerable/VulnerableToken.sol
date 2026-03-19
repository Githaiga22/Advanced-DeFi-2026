// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Integer Overflow — unchecked{} Arithmetic in Solidity 0.8+  │
// │  Vulnerability: High — Token Supply Manipulation                           │
// │  Module:       03 — Vulnerable Contracts                                   │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title VulnerableToken
/// @author Allan Robinson
/// @notice A minimal ERC-20-like token with unsafe arithmetic inside unchecked blocks.
/// @dev    WARNING (for auditors): Solidity 0.8+ auto-reverts on overflow by default.
///         However, the developer has wrapped critical arithmetic in `unchecked {}` for
///         "gas optimisation" — this disables the overflow check and reintroduces the
///         classic integer overflow vulnerability.
///         Attack: call burn(0) when balance is 0  →  0 - 0 = 0 (fine).
///                 call burn(1) when balance is 0  →  unchecked: 0 - 1 = type(uint256).max.
///         See docs/02_integer_overflow.md for the full explanation and fix.
contract VulnerableToken {
    // ─── Events ────────────────────────────────────────────────────────────────

    event Transfer(address indexed from, address indexed to, uint256 value);

    // ─── State ─────────────────────────────────────────────────────────────────
