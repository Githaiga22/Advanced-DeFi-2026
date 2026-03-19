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
    mapping(address => uint256) public rewards;

    uint256 public constant REWARD_DURATION = 30 days;
    uint256 public rewardRate; // rewards per second

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor() {
        owner = msg.sender;
        lastUpdateTime = block.timestamp;
    }

    // ─── Modifiers ─────────────────────────────────────────────────────────────

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    // ─── Functions ─────────────────────────────────────────────────────────────

    /// @notice Fund the reward pool.
    function fundRewards() external payable {
        require(msg.sender == owner, "Staking: not owner");
        rewardPool += msg.value;
        rewardRate = rewardPool / REWARD_DURATION;
        emit RewardFunded(msg.value);
    }

    /// @notice Stake ETH to earn rewards.
    function stake() external payable updateReward(msg.sender) {
        require(msg.value > 0, "Staking: zero amount");
        stakedBalance[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    /// @notice Unstake ETH.
    function unstake(uint256 _amount) external updateReward(msg.sender) {
        require(stakedBalance[msg.sender] >= _amount, "Staking: insufficient stake");
        stakedBalance[msg.sender] -= _amount;
        totalStaked -= _amount;

        (bool ok,) = msg.sender.call{value: _amount}("");
        require(ok, "Staking: transfer failed");

        emit Unstaked(msg.sender, _amount);
    }

    /// @notice Claim accumulated rewards.
    function claimReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "Staking: no rewards");

        rewards[msg.sender] = 0;

        // Bug 1: no reentrancy guard — reward claim can re-enter
        (bool ok,) = msg.sender.call{value: reward}("");
        require(ok, "Staking: reward transfer failed");

        emit RewardClaimed(msg.sender, reward);
    }

    // ─── View functions ────────────────────────────────────────────────────────

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) return rewardPerTokenStored;
        // Bug 2: precision loss — rewardRate * elapsed / totalStaked can be 0
        // when totalStaked is very large relative to rewardRate
        return rewardPerTokenStored + (rewardRate * (block.timestamp - lastUpdateTime)) / totalStaked;
    }

    function earned(address _account) public view returns (uint256) {
        return (stakedBalance[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18
            + rewards[_account];
    }
}
