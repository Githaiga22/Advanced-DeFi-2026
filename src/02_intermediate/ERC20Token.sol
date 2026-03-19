// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        ERC-20 Token Standard — From Scratch (No OpenZeppelin)       │
// │  Module:       02 — Intermediate                                            │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

import {console2} from "forge-std/console2.sol";

/// @title ERC20Token
/// @author Allan Robinson
/// @notice A minimal ERC-20 implementation written from scratch — no OpenZeppelin.
/// @dev    Purpose: understand the primitives before using libraries.
///         Implements EIP-20 in full, including allowances, mint, and burn.
///         Teaching points: storage layout, event semantics, allowance pattern.
contract ERC20Token {
    // ─── Errors ────────────────────────────────────────────────────────────────

    error ERC20__InsufficientBalance(uint256 available, uint256 required);
    error ERC20__InsufficientAllowance(uint256 available, uint256 required);
    error ERC20__TransferToZeroAddress();
    error ERC20__ApproveToZeroAddress();
    error ERC20__MintToZeroAddress();
    error ERC20__BurnExceedsBalance();
    error ERC20__NotOwner();

    // ─── Events ────────────────────────────────────────────────────────────────

    /// @notice Emitted on any token transfer, including mint (from=0) and burn (to=0).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when an allowance is set via approve().
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ─── State ─────────────────────────────────────────────────────────────────

    string private s_name;
    string private s_symbol;
    uint8 private immutable i_decimals;
    uint256 private s_totalSupply;

    address private immutable i_owner;

    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) private s_allowances;

    // ─── Constructor ───────────────────────────────────────────────────────────

    /// @param _name     Human-readable token name (e.g. "Cyfrin Token").
    /// @param _symbol   Ticker symbol (e.g. "CFN").
    /// @param _decimals Token precision (18 for ETH-like).
    /// @param _initialSupply Tokens minted to deployer at construction (in whole tokens).
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        s_name = _name;
        s_symbol = _symbol;
        i_decimals = _decimals;
        i_owner = msg.sender;

        if (_initialSupply > 0) {
            _mint(msg.sender, _initialSupply * (10 ** _decimals));
        }
    }
