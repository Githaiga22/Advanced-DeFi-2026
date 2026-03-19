// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Price Oracle Manipulation + Flash Loan Attack                │
// │  Vulnerability: Critical — Collateral Value Can Be Artificially Inflated  │
// │  Module:       03 — Vulnerable Contracts                                   │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title MockAMM
/// @notice Minimal constant-product AMM (like Uniswap v2) used as a spot-price oracle.
/// @dev    Included inline so the full attack surface is visible in one file.
contract MockAMM {
    uint256 public reserveETH;
    uint256 public reserveToken;

    constructor(uint256 _ethReserve, uint256 _tokenReserve) {
        reserveETH = _ethReserve;
        reserveToken = _tokenReserve;
    }

    /// @notice Get the current spot price: how many tokens per 1 ETH.
    function getTokensPerETH() external view returns (uint256) {
        if (reserveETH == 0) return 0;
        return (reserveToken * 1e18) / reserveETH;
    }

    /// @notice Swap ETH for tokens (simplified, no fee).
    /// @dev    x * y = k  →  newToken = k / (oldETH + amountIn)
    function swapETHForTokens() external payable returns (uint256 tokensOut) {
        uint256 k = reserveETH * reserveToken;
        uint256 newReserveETH = reserveETH + msg.value;
        uint256 newReserveToken = k / newReserveETH;
        tokensOut = reserveToken - newReserveToken;
        reserveETH = newReserveETH;
        reserveToken = newReserveToken;
    }

    /// @notice Swap tokens back for ETH.
    function swapTokensForETH(uint256 _tokenAmount) external returns (uint256 ethOut) {
        uint256 k = reserveETH * reserveToken;
        uint256 newReserveToken = reserveToken + _tokenAmount;
        uint256 newReserveETH = k / newReserveToken;
        ethOut = reserveETH - newReserveETH;
        reserveETH = newReserveETH;
        reserveToken = newReserveToken;
        (bool ok,) = msg.sender.call{value: ethOut}("");
        require(ok, "MockAMM: ETH transfer failed");
    }

    receive() external payable {}
}

/// @title VulnerableOracle
/// @author Allan Robinson
/// @notice A lending protocol that uses the AMM's spot price to determine
///         how much a user can borrow.
/// @dev    WARNING (for auditors): The protocol reads the spot price directly
///         from the AMM in the same transaction as the loan. An attacker can:
///           1. Take a large "flash-swap" to inflate the AMM price.
///           2. Call borrow() while the price is inflated → receive far more than fair value.
///           3. Reverse the swap in the same transaction.
///         This is a classic price oracle manipulation / flash loan attack.
///         See docs/08_price_oracle_manipulation.md for the full explanation and fixes.
contract VulnerableOracle {
    // ─── State ─────────────────────────────────────────────────────────────────

    MockAMM public amm;
    mapping(address => uint256) public tokenDeposits;
    mapping(address => uint256) public ethBorrowed;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor(address _amm) {
        amm = MockAMM(payable(_amm));
    }

    // ─── Functions ─────────────────────────────────────────────────────────────

    /// @notice Deposit tokens as collateral.
    function depositCollateral(uint256 _amount) external {
        tokenDeposits[msg.sender] += _amount;
    }

    /// @notice Borrow ETH against your token collateral.
    /// @dev    BUG: Reads spot price from the AMM — easily manipulated in the same tx.
    ///         Borrow limit = collateral * spotPrice / 1e18.
    function borrow(uint256 _tokenAmount) external {
        require(tokenDeposits[msg.sender] >= _tokenAmount, "VulnerableOracle: insufficient collateral");

        // ❌ Spot price read — can be inflated by a large AMM swap in the same transaction
        uint256 tokensPerETH = amm.getTokensPerETH();
        require(tokensPerETH > 0, "VulnerableOracle: oracle unavailable");

        // ethValue = tokenAmount / tokensPerETH * 1e18
        uint256 ethValue = (_tokenAmount * 1e18) / tokensPerETH;

        require(address(this).balance >= ethValue, "VulnerableOracle: insufficient liquidity");

        tokenDeposits[msg.sender] -= _tokenAmount;
        ethBorrowed[msg.sender] += ethValue;

        (bool ok,) = msg.sender.call{value: ethValue}("");
        require(ok, "VulnerableOracle: ETH transfer failed");
    }

    /// @notice Repay borrowed ETH.
    function repay() external payable {
        require(ethBorrowed[msg.sender] >= msg.value, "VulnerableOracle: overpayment");
        ethBorrowed[msg.sender] -= msg.value;
    }

    receive() external payable {}
}
