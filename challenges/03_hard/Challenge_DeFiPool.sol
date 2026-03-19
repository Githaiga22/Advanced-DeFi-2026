// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │  Topic:        Oracle Manipulation + Reentrancy + Flash Loan (Bug Bounty)   │
// │  Difficulty:   Hard — 3+ hidden bugs (325+ pts + 50 bonus each for PoC)   │
// │  Module:       Bug Bounty Challenges — Level 3                              │
// │  Created:      2026-03-19                                                   │
// │  Last Updated: 2026-03-19                                                   │
// └─────────────────────────────────────────────────────────────────────────────┘

/// @title Challenge_DeFiPool
/// @author Allan Robinson
/// @notice A liquidity pool that allows users to:
///           - Provide liquidity (ETH + token) and receive LP shares
///           - Swap ETH for tokens using the pool price
///           - Borrow ETH against token collateral (priced by the pool)
///           - Flash-loan ETH (repaid in same tx with a 0.3% fee)
///
/// ╔══════════════════════════════════════════════════════════════╗
/// ║  BUG BOUNTY CHALLENGE — HARD (3+ bugs, 325+ points)         ║
/// ║  Bug 1: Critical ~100 pts   |  Bug 2: High ~75 pts          ║
/// ║  Bug 3: High ~75 pts        |  Bug 4: Medium ~50 pts (bonus)║
/// ║  Write PoC exploit tests for +50 bonus points per bug.      ║
/// ╚══════════════════════════════════════════════════════════════╝
contract Challenge_DeFiPool {
    // ─── Events ────────────────────────────────────────────────────────────────

    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount, uint256 shares);
    event Swapped(address indexed user, uint256 ethIn, uint256 tokensOut);
    event Borrowed(address indexed user, uint256 collateral, uint256 ethBorrowed);
    event FlashLoan(address indexed borrower, uint256 amount, uint256 fee);

    // ─── State ─────────────────────────────────────────────────────────────────

    address public owner;

    uint256 public ethReserve;
    uint256 public tokenReserve;
    uint256 public totalShares;

    mapping(address => uint256) public shares;
    mapping(address => uint256) public tokenCollateral;
    mapping(address => uint256) public ethDebt;
    mapping(address => uint256) public tokenBalances;

    bool private _flashLoanActive;

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor() {
        owner = msg.sender;
    }

    // ─── Liquidity ─────────────────────────────────────────────────────────────

    /// @notice Add liquidity. Send ETH, specify token amount.
    function addLiquidity(uint256 _tokenAmount) external payable {
        require(msg.value > 0 && _tokenAmount > 0, "Pool: zero amount");

        tokenBalances[msg.sender] -= _tokenAmount; // assume token is internal ledger

        uint256 newShares;
        if (totalShares == 0) {
            newShares = msg.value;
        } else {
            newShares = (msg.value * totalShares) / ethReserve;
        }

        ethReserve += msg.value;
        tokenReserve += _tokenAmount;
        shares[msg.sender] += newShares;
        totalShares += newShares;

        emit LiquidityAdded(msg.sender, msg.value, _tokenAmount, newShares);
    }

    // ─── Swap ──────────────────────────────────────────────────────────────────

    /// @notice Swap ETH for tokens using the constant-product formula.
    function swapETHForTokens() external payable returns (uint256 tokensOut) {
        require(msg.value > 0, "Pool: zero ETH");
        require(tokenReserve > 0 && ethReserve > 0, "Pool: no liquidity");

        // x * y = k — no fee
        uint256 k = ethReserve * tokenReserve;
        uint256 newEthReserve = ethReserve + msg.value;
        uint256 newTokenReserve = k / newEthReserve;
        tokensOut = tokenReserve - newTokenReserve;

        ethReserve = newEthReserve;
        tokenReserve = newTokenReserve;
        tokenBalances[msg.sender] += tokensOut;

        emit Swapped(msg.sender, msg.value, tokensOut);
    }

    // ─── Lending ───────────────────────────────────────────────────────────────

    /// @notice Deposit token collateral, borrow ETH at spot price.
    /// @dev    Bug 1: spot price oracle — manipulable by large swap in same tx.
    function borrow(uint256 _tokenCollateral) external {
        require(_tokenCollateral > 0, "Pool: zero collateral");
        require(tokenBalances[msg.sender] >= _tokenCollateral, "Pool: insufficient tokens");

        // Bug 1: spot price read from pool — can be inflated via large swap
        uint256 ethValue = (_tokenCollateral * ethReserve) / tokenReserve;
        require(address(this).balance >= ethValue, "Pool: insufficient ETH");

        tokenBalances[msg.sender] -= _tokenCollateral;
        tokenCollateral[msg.sender] += _tokenCollateral;
        ethDebt[msg.sender] += ethValue;

        emit Borrowed(msg.sender, _tokenCollateral, ethValue);

        // Bug 2: no reentrancy guard — callback can re-enter borrow()
        (bool ok,) = msg.sender.call{value: ethValue}("");
        require(ok, "Pool: borrow transfer failed");
    }

    // ─── Flash loan ────────────────────────────────────────────────────────────

    /// @notice Flash-loan ETH. Borrower must repay principal + 0.3% fee in same tx.
    /// @param _amount Amount of ETH to borrow.
    /// @param _receiver Contract to receive the ETH and execute logic.
    function flashLoan(uint256 _amount, address _receiver) external {
        require(_amount > 0, "Pool: zero amount");
        require(address(this).balance >= _amount, "Pool: insufficient ETH");

        uint256 fee = (_amount * 3) / 1000; // 0.3%
        uint256 balanceBefore = address(this).balance;

        _flashLoanActive = true;

        // Bug 3: no check that _receiver implements the callback correctly
        // A malicious receiver can re-enter other pool functions during the loan
        (bool ok,) = _receiver.call{value: _amount}(abi.encodeWithSignature("onFlashLoan(uint256,uint256)", _amount, fee));
        require(ok, "Pool: flash loan callback failed");

        _flashLoanActive = false;

        // Bug 4: fee check is weak — balance check doesn't account for tokens
        require(address(this).balance >= balanceBefore + fee, "Pool: flash loan not repaid");

        emit FlashLoan(_receiver, _amount, fee);
    }

    // ─── View ──────────────────────────────────────────────────────────────────

    function getSpotPrice() external view returns (uint256 tokensPerETH) {
        if (ethReserve == 0) return 0;
        return (tokenReserve * 1e18) / ethReserve;
    }

    receive() external payable {}
}
