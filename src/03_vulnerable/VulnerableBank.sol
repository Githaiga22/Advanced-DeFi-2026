// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Reentrancy Attack — CEI Pattern Violation                    │
// │  Vulnerability: Critical — Funds at Risk                                   │
// │  Module:       03 — Vulnerable Contracts                                   │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title VulnerableBank
/// @author Allan Robinson
/// @notice A simple ETH savings bank. Users deposit ETH and can withdraw it at any time.
/// @dev    WARNING (for auditors): This contract deliberately contains a reentrancy
///         vulnerability. It violates the Checks-Effects-Interactions (CEI) pattern —
///         the external call is made BEFORE the balance is updated.
///         See docs/01_reentrancy.md for the full explanation and fix.
contract VulnerableBank {
    // ─── Events ────────────────────────────────────────────────────────────────

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // ─── State ─────────────────────────────────────────────────────────────────

    mapping(address => uint256) public balances;

    // ─── External functions ────────────────────────────────────────────────────

    /// @notice Deposit ETH into the bank.
    function deposit() external payable {
        require(msg.value > 0, "VulnerableBank: zero deposit");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Withdraw your full balance.
    /// @dev    BUG: External call happens BEFORE balance is zeroed.
    ///         A malicious receive() can re-enter this function and drain the bank.
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "VulnerableBank: nothing to withdraw");

        // ❌ INTERACTION before EFFECT — reentrancy attack vector
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "VulnerableBank: transfer failed");

        // ❌ State updated AFTER the external call — too late
        balances[msg.sender] = 0;

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Returns the contract's total ETH balance.
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
