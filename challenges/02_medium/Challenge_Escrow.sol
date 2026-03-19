// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        tx.origin Phishing + Timestamp Dependence (Bug Bounty)       │
// │  Difficulty:   Medium — 2 hidden bugs (150 pts + 50 bonus each for PoC)    │
// │  Module:       Bug Bounty Challenges — Level 2                              │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title Challenge_Escrow
/// @author Allan Robinson
/// @notice A time-locked escrow. The depositor locks ETH until a deadline,
///         after which the beneficiary can claim it — or the depositor can
///         reclaim if disputed.
///
/// ╔══════════════════════════════════════════════════════════════╗
/// ║  BUG BOUNTY CHALLENGE — MEDIUM (2 hidden bugs, 150 points)  ║
/// ║  Bug 1: ~75 pts  |  Bug 2: ~75 pts                          ║
/// ║  Write a PoC exploit test for +50 bonus points per bug.     ║
/// ╚══════════════════════════════════════════════════════════════╝
contract Challenge_Escrow {
    // ─── Events ────────────────────────────────────────────────────────────────

    event EscrowCreated(uint256 indexed id, address depositor, address beneficiary, uint256 amount, uint256 deadline);
    event EscrowReleased(uint256 indexed id, address beneficiary, uint256 amount);
    event EscrowRefunded(uint256 indexed id, address depositor, uint256 amount);

    // ─── State ─────────────────────────────────────────────────────────────────

    struct EscrowRecord {
        address depositor;
        address beneficiary;
        uint256 amount;
        uint256 deadline;
        bool released;
    }

    uint256 public nextId;
    mapping(uint256 => EscrowRecord) public escrows;

    // ─── Functions ─────────────────────────────────────────────────────────────

    /// @notice Create a new escrow.
    /// @param _beneficiary Who receives the funds.
    /// @param _lockDuration How long (in seconds) before the beneficiary can claim.
    function createEscrow(address _beneficiary, uint256 _lockDuration) external payable returns (uint256 id) {
        require(msg.value > 0, "Escrow: zero amount");
        require(_beneficiary != address(0), "Escrow: zero address");

        id = nextId++;
        escrows[id] = EscrowRecord({
            depositor: msg.sender,
            beneficiary: _beneficiary,
            amount: msg.value,
            deadline: block.timestamp + _lockDuration,
            released: false
        });

        emit EscrowCreated(id, msg.sender, _beneficiary, msg.value, block.timestamp + _lockDuration);
    }

    /// @notice Release funds to the beneficiary after deadline.
    /// @dev    Bug 1: uses tx.origin instead of msg.sender for the auth check.
    function release(uint256 _id) external {
        EscrowRecord storage record = escrows[_id];
        require(!record.released, "Escrow: already released");
        require(block.timestamp >= record.deadline, "Escrow: still locked");
