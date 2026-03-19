// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Share-Based Accounting (ERC-4626), Manual Reentrancy Guard   │
// │  Module:       02 — Intermediate                                            │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

import {ERC20Token} from "./ERC20Token.sol";

/// @title SimpleVault
/// @author Allan Robinson
/// @notice A share-based ETH vault. Depositors receive vault shares proportional
///         to their contribution. Shares can be redeemed for the underlying ETH.
/// @dev    Teaching points:
///           - Share-based accounting (ERC-4626 concept, manual implementation)
///           - Manual reentrancy mutex (before using OZ ReentrancyGuard)
///           - _convertToShares / _convertToAssets rounding decisions
contract SimpleVault {
    // ─── Errors ────────────────────────────────────────────────────────────────

    error SimpleVault__ZeroDeposit();
    error SimpleVault__ZeroShares();
    error SimpleVault__InsufficientShares(uint256 available, uint256 required);
    error SimpleVault__ReentrantCall();
    error SimpleVault__TransferFailed();

    // ─── Events ────────────────────────────────────────────────────────────────

    /// @notice Emitted when ETH is deposited and shares are minted.
    event Deposited(address indexed user, uint256 ethAmount, uint256 sharesIssued);

    /// @notice Emitted when shares are redeemed for ETH.
    event Withdrawn(address indexed user, uint256 sharesRedeemed, uint256 ethReturned);

    // ─── State ─────────────────────────────────────────────────────────────────

    /// @dev Manual reentrancy lock — true = locked.
    bool private s_locked;

    /// @dev Total vault shares in existence.
    uint256 private s_totalShares;

    /// @dev Each user's share balance.
    mapping(address => uint256) private s_shares;

    // ─── Modifiers ─────────────────────────────────────────────────────────────

    /// @dev Reverts on reentrant calls. Cheaper than OZ ReentrancyGuard for teaching clarity.
    modifier nonReentrant() {
        if (s_locked) revert SimpleVault__ReentrantCall();
        s_locked = true;
        _;
        s_locked = false;
    }

    // ─── External functions ────────────────────────────────────────────────────

    /// @notice Deposit ETH and receive vault shares.
    /// @dev    Shares = (deposit / totalAssets) * totalShares.
    ///         First depositor gets shares equal to wei deposited (1:1 seed).
    function deposit() external payable nonReentrant {
        if (msg.value == 0) revert SimpleVault__ZeroDeposit();

        uint256 shares = _convertToShares(msg.value);
        if (shares == 0) revert SimpleVault__ZeroShares();

        s_shares[msg.sender] += shares;
        s_totalShares += shares;

        emit Deposited(msg.sender, msg.value, shares);
    }

    /// @notice Redeem `_shares` for the proportional amount of ETH.
    /// @param _shares Number of shares to redeem.
    function withdraw(uint256 _shares) external nonReentrant {
        if (_shares == 0) revert SimpleVault__ZeroShares();

        uint256 userShares = s_shares[msg.sender];
        if (userShares < _shares) {
            revert SimpleVault__InsufficientShares(userShares, _shares);
        }

        uint256 ethAmount = _convertToAssets(_shares);

        // ── Effects (before external call — CEI pattern) ─────────────────────
        s_shares[msg.sender] -= _shares;
        s_totalShares -= _shares;

        emit Withdrawn(msg.sender, _shares, ethAmount);

        // ── Interaction ──────────────────────────────────────────────────────
        (bool success,) = msg.sender.call{value: ethAmount}("");
        if (!success) revert SimpleVault__TransferFailed();
    }

    // ─── View functions ────────────────────────────────────────────────────────
