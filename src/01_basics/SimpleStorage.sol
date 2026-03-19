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

