// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Reentrancy + Precision Loss / Rounding Errors (Bug Bounty)   │
// │  Difficulty:   Medium — 2 hidden bugs (150 pts + 50 bonus each for PoC)    │
// │  Module:       Bug Bounty Challenges — Level 2                              │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title Challenge_Staking
/// @author Allan Robinson
/// @notice A staking rewards contract. Users stake ETH and earn rewards
///         proportional to their share of the pool over time.
///
/// ╔══════════════════════════════════════════════════════════════╗
/// ║  BUG BOUNTY CHALLENGE — MEDIUM (2 hidden bugs, 150 points)  ║
/// ║  Bug 1: ~75 pts  |  Bug 2: ~75 pts                          ║
/// ║  Write a PoC exploit test for +50 bonus points per bug.     ║
/// ╚══════════════════════════════════════════════════════════════╝
contract Challenge_Staking {
    // ─── Events ────────────────────────────────────────────────────────────────

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event RewardFunded(uint256 amount);

    // ─── State ─────────────────────────────────────────────────────────────────

    address public owner;

    uint256 public totalStaked;
    uint256 public rewardPool;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public userRewardPerTokenPaid;
