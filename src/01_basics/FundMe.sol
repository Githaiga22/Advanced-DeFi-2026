// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        ETH Handling, CEI Pattern, Pull Payment, receive/fallback    │
// │  Module:       01 — Basics                                                  │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

import {console2} from "forge-std/console2.sol";

/// @title FundMe
/// @author Allan Robinson
/// @notice A simple crowdfunding contract where anyone can fund and the owner
///         can withdraw accumulated ETH.
/// @dev    Teaches: ETH handling (msg.value / msg.sender), payable functions,
///         receive() + fallback(), pull-payment withdrawal, CEI pattern,
///         low-level call vs transfer.
contract FundMe {
    // ─── Errors ────────────────────────────────────────────────────────────────

    /// @notice Sent ETH is below the required minimum.
    /// @param sent    The amount the caller sent (in wei).
    /// @param minimum The minimum required (in wei).
    error FundMe__BelowMinimum(uint256 sent, uint256 minimum);

    /// @notice Caller is not the contract owner.
    error FundMe__NotOwner();

    /// @notice There is nothing to withdraw.
    error FundMe__NothingToWithdraw();

    // ─── Events ────────────────────────────────────────────────────────────────

    /// @notice Emitted when a funder contributes ETH.
    /// @param funder The address that sent ETH.
    /// @param amount The amount sent (in wei).
    event Funded(address indexed funder, uint256 amount);

    /// @notice Emitted when the owner withdraws the contract balance.
    /// @param owner  The owner address.
    /// @param amount The total ETH withdrawn (in wei).
    event Withdrawn(address indexed owner, uint256 amount);

    // ─── Constants ─────────────────────────────────────────────────────────────

    /// @dev Minimum ETH contribution: 0.01 ETH.
    uint256 public constant MINIMUM_ETH = 0.01 ether;

    // ─── State ─────────────────────────────────────────────────────────────────

    /// @dev The address that deployed this contract.
    address private immutable i_owner;

    /// @dev Tracks each address's total funded amount.
    mapping(address => uint256) private s_addressToAmountFunded;

    /// @dev Ordered list of unique funders (for iteration during withdrawal).
    address[] private s_funders;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor() {
        i_owner = msg.sender;
    }

    // ─── Modifiers ─────────────────────────────────────────────────────────────

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // ─── External / public functions ───────────────────────────────────────────

    /// @notice Send ETH to fund this contract.
    /// @dev    Reverts if msg.value < MINIMUM_ETH.
    ///         First-time funders are added to s_funders for bookkeeping.
    function fund() public payable {
        if (msg.value < MINIMUM_ETH) {
            revert FundMe__BelowMinimum(msg.value, MINIMUM_ETH);
        }

        console2.log("FundMe.fund: funder=%s amount=%d", msg.sender, msg.value);

        // Track first-time funders
        if (s_addressToAmountFunded[msg.sender] == 0) {
            s_funders.push(msg.sender);
        }

        s_addressToAmountFunded[msg.sender] += msg.value;

        emit Funded(msg.sender, msg.value);
    }

    /// @notice Withdraw all ETH to the owner.
    /// @dev    Pull-payment pattern — only owner can trigger.
    ///         CEI: state cleared before external call.
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert FundMe__NothingToWithdraw();

        // ── Checks + Effects ────────────────────────────────────────────────
        // Reset all funder balances before any external call (CEI pattern).
        uint256 funderCount = s_funders.length;
        for (uint256 i = 0; i < funderCount; i++) {
            s_addressToAmountFunded[s_funders[i]] = 0;
        }
        delete s_funders;

        emit Withdrawn(i_owner, balance);

        // ── Interaction ─────────────────────────────────────────────────────
        // Low-level call forwards all gas and propagates failures.
        (bool success,) = i_owner.call{value: balance}("");
        require(success, "FundMe: ETH transfer failed");
    }

    // ─── View functions ────────────────────────────────────────────────────────

    /// @notice Returns how much ETH a specific address has contributed.
    /// @param _funder The funder's address.
    /// @return The total funded amount in wei.
    function getAmountFunded(address _funder) external view returns (uint256) {
        return s_addressToAmountFunded[_funder];
    }

    /// @notice Returns the full list of funders.
    function getFunders() external view returns (address[] memory) {
        return s_funders;
    }

    /// @notice Returns the contract owner.
    function getOwner() external view returns (address) {
        return i_owner;
    }

    /// @notice Returns the contract's current ETH balance.
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ─── Receive / Fallback ────────────────────────────────────────────────────

    /// @dev Plain ETH transfers route to fund().
    receive() external payable {
        fund();
    }

    /// @dev Calls with non-empty calldata that match nothing also route to fund().
    fallback() external payable {
        fund();
    }
}
