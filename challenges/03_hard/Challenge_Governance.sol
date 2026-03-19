// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Flash Loan Vote Manipulation + tx.origin + DoS (Bug Bounty)  │
// │  Difficulty:   Hard — 3+ hidden bugs (300+ pts + 50 bonus each for PoC)   │
// │  Module:       Bug Bounty Challenges — Level 3                              │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title Challenge_Governance
/// @author Allan Robinson
/// @notice A DAO governance contract. Token holders create proposals, vote,
///         and execute them after quorum is reached.
///
/// ╔══════════════════════════════════════════════════════════════╗
/// ║  BUG BOUNTY CHALLENGE — HARD (3+ bugs, 300+ points)         ║
/// ║  Bug 1: Critical ~100 pts   |  Bug 2: High ~75 pts          ║
/// ║  Bug 3: Medium ~50 pts      |  Bug 4: Medium ~50 pts (bonus)║
/// ║  Write PoC exploit tests for +50 bonus points per bug.      ║
/// ╚══════════════════════════════════════════════════════════════╝
contract Challenge_Governance {
    // ─── Events ────────────────────────────────────────────────────────────────

    event ProposalCreated(uint256 indexed id, address proposer, string description);
    event Voted(uint256 indexed id, address voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed id);

    // ─── State ─────────────────────────────────────────────────────────────────

    struct Proposal {
        address proposer;
        string description;
        address target;
        bytes callData;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 deadline;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    address public owner;
    address public governanceToken; // just address for simplicity

    uint256 public proposalCount;
    uint256 public quorum = 100e18; // 100 tokens needed
    uint256 public votingPeriod = 3 days;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public tokenBalance; // simplified token ledger

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor() {
        owner = msg.sender;
    }

    // ─── Admin ─────────────────────────────────────────────────────────────────

    function grantTokens(address _to, uint256 _amount) external {
        require(msg.sender == owner, "Gov: not owner");
        tokenBalance[_to] += _amount;
    }

    // ─── Governance ────────────────────────────────────────────────────────────

    /// @notice Create a governance proposal.
    function propose(string calldata _description, address _target, bytes calldata _callData)
        external
        returns (uint256 id)
    {
        require(tokenBalance[msg.sender] >= 1e18, "Gov: insufficient tokens to propose");
        id = proposalCount++;
        Proposal storage p = proposals[id];
        p.proposer = msg.sender;
        p.description = _description;
        p.target = _target;
        p.callData = _callData;
        p.deadline = block.timestamp + votingPeriod;
        emit ProposalCreated(id, msg.sender, _description);
    }

    /// @notice Vote on a proposal.
    /// @dev    Bug 1: voting weight is read at vote time — flash loan attack possible.
    ///         An attacker can borrow tokens, vote with huge weight, repay in same tx.
    function vote(uint256 _id, bool _support) external {
        Proposal storage p = proposals[_id];
        require(block.timestamp < p.deadline, "Gov: voting ended");
        require(!p.hasVoted[msg.sender], "Gov: already voted");

        // Bug 1: snapshot not taken at proposal creation — current balance used
        uint256 weight = tokenBalance[msg.sender];
        require(weight > 0, "Gov: no voting power");

        p.hasVoted[msg.sender] = true;

