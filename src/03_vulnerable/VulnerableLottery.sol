// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Timestamp Dependence — Weak Randomness via block.timestamp   │
// │  Vulnerability: High — Validator Can Manipulate Lottery Outcome            │
// │  Module:       03 — Vulnerable Contracts                                   │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title VulnerableLottery
/// @author Allan Robinson
/// @notice A lottery where participants buy tickets and a random winner is
///         drawn when the lottery closes.
/// @dev    WARNING (for auditors): The "randomness" is derived from block.timestamp.
///         Validators / miners control timestamp within a ~15 second window.
///         A validator who holds a ticket can:
///           1. Wait until they are scheduled to propose a block.
///           2. Try different timestamp values within the valid range.
///           3. Include the block only if the timestamp makes them the winner.
///         This gives the validator a disproportionate chance of winning.
///         See docs/06_timestamp_dependence.md for the full explanation and Chainlink VRF fix.
contract VulnerableLottery {
    // ─── Events ────────────────────────────────────────────────────────────────

    event TicketPurchased(address indexed player);
    event WinnerSelected(address indexed winner, uint256 prize);

