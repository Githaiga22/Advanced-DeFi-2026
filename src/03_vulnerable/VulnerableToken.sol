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

    string public name = "VulnerableToken";
    string public symbol = "VULN";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 1e18;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // ─── Functions ─────────────────────────────────────────────────────────────

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(_to != address(0), "zero address");
        // ❌ unchecked disables overflow protection on subtraction
        unchecked {
            balanceOf[msg.sender] -= _amount;
            balanceOf[_to] += _amount;
        }
        emit Transfer(msg.sender, _to, _amount);
        return true;
