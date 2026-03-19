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
    // ─── Events ────────────────────────────────────────────────────────────────

    event NewHighBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);

    // ─── State ─────────────────────────────────────────────────────────────────

    address public owner;
    uint256 public auctionEndTime;
    address public highestBidder;
    uint256 public highestBid;
    bool public ended;

    // Unbounded array of all historical bidders (Bug 2)
    address[] public allBidders;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor(uint256 _durationSeconds) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _durationSeconds;
    }

    // ─── Functions ─────────────────────────────────────────────────────────────

    /// @notice Place a bid. Must exceed current highest bid.
    /// @dev    BUG: refund via push payment — a reverting receive() blocks the auction.
    function bid() external payable {
        require(block.timestamp < auctionEndTime, "VulnerableAuction: auction ended");
        require(msg.value > highestBid, "VulnerableAuction: bid too low");
