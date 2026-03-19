// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Solidity Basics — State Variables, Mappings, Events          │
// │  Module:       01 — Basics                                                  │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

import {console2} from "forge-std/console2.sol";

/// @title SimpleStorage
/// @author Allan Robinson
/// @notice A simple key-value store mapping addresses to uint256 values.
///         Teaches: state variables, mappings, events, modifiers, custom errors.
/// @dev    Owner can withdraw any ETH accidentally sent to the contract.
contract SimpleStorage {
    // ─── Errors ────────────────────────────────────────────────────────────────

    /// @notice Caller is not the contract owner.
    error SimpleStorage__NotOwner();

    /// @notice Cannot store a zero value.
    error SimpleStorage__ZeroValue();

    // ─── Events ────────────────────────────────────────────────────────────────

    /// @notice Emitted whenever a value is stored or updated.
    /// @param user     The address whose value changed.
    /// @param oldValue The previous stored value.
    /// @param newValue The new stored value.
    event StoredValueUpdated(address indexed user, uint256 oldValue, uint256 newValue);

    /// @notice Emitted when the owner withdraws ETH from the contract.
    /// @param owner  The owner address.
    /// @param amount The ETH amount withdrawn (in wei).
    event OwnerWithdrawn(address indexed owner, uint256 amount);

    // ─── State ─────────────────────────────────────────────────────────────────

    /// @dev The address that deployed this contract.
    address private immutable i_owner;

    /// @dev Each address maps to its stored uint256 value.
    mapping(address => uint256) private s_storedValues;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor() {
        i_owner = msg.sender;
    }

    // ─── Modifiers ─────────────────────────────────────────────────────────────

    /// @dev Reverts with SimpleStorage__NotOwner if caller is not the owner.
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert SimpleStorage__NotOwner();
        _;
    }

    // ─── External functions ────────────────────────────────────────────────────

    /// @notice Store a value under your address.
    /// @dev    Reverts if `_value` is zero. Emits StoredValueUpdated.
    ///         console2.log is a no-op outside the Forge test environment.
    /// @param _value The uint256 value to store.
    function store(uint256 _value) external {
        if (_value == 0) revert SimpleStorage__ZeroValue();
