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

    // ─── State ─────────────────────────────────────────────────────────────────

    address public owner;
    uint256 public ticketPrice;
    uint256 public lotteryEndTime;
    address[] public players;
    bool public drawn;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor(uint256 _ticketPrice, uint256 _durationSeconds) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        lotteryEndTime = block.timestamp + _durationSeconds;
    }

    // ─── Functions ─────────────────────────────────────────────────────────────

    /// @notice Buy a lottery ticket.
    function buyTicket() external payable {
        require(block.timestamp < lotteryEndTime, "VulnerableLottery: lottery closed");
        require(msg.value == ticketPrice, "VulnerableLottery: wrong ticket price");
        players.push(msg.sender);
        emit TicketPurchased(msg.sender);
    }

    /// @notice Draw the winner after the lottery ends.
    /// @dev    BUG: randomness comes from block.timestamp — manipulable by validators.
    function drawWinner() external {
        require(block.timestamp >= lotteryEndTime, "VulnerableLottery: still running");
        require(!drawn, "VulnerableLottery: already drawn");
        require(players.length > 0, "VulnerableLottery: no players");
        drawn = true;

        // ❌ block.timestamp is controlled by the block proposer
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp, // ❌ manipulable
                    block.prevrandao, // ❌ also manipulable post-merge (partially)
                    players.length
                )
            )
        ) % players.length;

        address winner = players[randomIndex];
        uint256 prize = address(this).balance;

        emit WinnerSelected(winner, prize);

        (bool ok,) = winner.call{value: prize}("");
        require(ok, "VulnerableLottery: prize transfer failed");
    }

    /// @notice Returns the number of players.
    function getPlayerCount() external view returns (uint256) {
        return players.length;
    }
}
