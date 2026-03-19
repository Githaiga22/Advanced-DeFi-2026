// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Access Control — tx.origin Phishing + Unprotected selfdest  │
// │  Vulnerability: Critical — Contract Can Be Destroyed via Phishing Attack  │
// │  Module:       03 — Vulnerable Contracts                                   │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title VulnerableAccessControl
/// @author Allan Robinson
/// @notice A simple contract with admin-only functions protected by… tx.origin.
/// @dev    WARNING (for auditors): Two access-control vulnerabilities exist.
///
///         Bug 1 — tx.origin phishing:
///           The onlyOwner modifier checks tx.origin instead of msg.sender.
///           tx.origin is ALWAYS the EOA that originated the outer transaction.
///           A malicious contract can trick the owner into calling it, and then
///           forward a call to this contract — tx.origin will still be the owner,
///           so the modifier passes even though msg.sender is the attacker.
///
///         Bug 2 — Unprotected selfdestruct:
///           The destroy() function calls selfdestruct(owner). It is only
///           guarded by the tx.origin check (Bug 1), so an attacker who exploits
