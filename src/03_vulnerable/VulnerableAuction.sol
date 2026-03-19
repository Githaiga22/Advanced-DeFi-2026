// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        DoS Attack — Push Payment + Unbounded Loop                  │
// │  Vulnerability: High — Auction Can Be Permanently Frozen                  │
// │  Module:       03 — Vulnerable Contracts                                   │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title VulnerableAuction
/// @author Allan Robinson
/// @notice An English auction where the highest bidder wins. Previous highest
///         bidder is refunded automatically when outbid.
/// @dev    WARNING (for auditors): Two DoS vulnerabilities exist.
///
///         Bug 1 — Push-payment refund:
///           When a new highest bid arrives, the contract immediately pushes ETH
///           back to the previous highest bidder. A malicious bidder can deploy a
///           contract whose receive() always reverts, permanently blocking any
///           higher bid and freezing the auction.
///
///         Bug 2 — Unbounded loop in finalise():
///           finalise() iterates over ALL past bidders to clear their records.
///           An attacker can spam bids to grow this array until the gas cost
///           of finalise() exceeds the block gas limit, making it uncallable.
///
///         See docs/04_dos_attack.md for the full explanation and fixes.
contract VulnerableAuction {
