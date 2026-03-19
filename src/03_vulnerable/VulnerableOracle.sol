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
