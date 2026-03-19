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

    // ─── EIP-20 Functions ──────────────────────────────────────────────────────

    /// @notice Returns the total token supply.
    function totalSupply() external view returns (uint256) {
        return s_totalSupply;
    }

    /// @notice Returns the token balance of `_account`.
    /// @param _account Address to query.
    function balanceOf(address _account) external view returns (uint256) {
        return s_balances[_account];
    }

    /// @notice Transfer `_amount` tokens from caller to `_to`.
    /// @param _to     Recipient address.
    /// @param _amount Number of tokens (in smallest unit).
    /// @return True on success.
    function transfer(address _to, uint256 _amount) external returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    /// @notice Returns how many tokens `_spender` is allowed to spend on behalf of `_owner`.
    /// @param _owner   Token holder address.
    /// @param _spender Authorized spender address.
    function allowance(address _owner, address _spender) external view returns (uint256) {
        return s_allowances[_owner][_spender];
    }

    /// @notice Approve `_spender` to spend up to `_amount` of your tokens.
    /// @dev    Setting to 0 revokes allowance. Standard front-running risk applies;
    ///         use increaseAllowance / decreaseAllowance in production.
    /// @param _spender Address to authorize.
    /// @param _amount  Maximum tokens allowed to spend.
    /// @return True on success.
    function approve(address _spender, uint256 _amount) external returns (bool) {
        if (_spender == address(0)) revert ERC20__ApproveToZeroAddress();
        s_allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @notice Transfer tokens from `_from` to `_to` using the caller's allowance.
    /// @param _from   Token holder address.
    /// @param _to     Recipient address.
    /// @param _amount Number of tokens to transfer.
    /// @return True on success.
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        uint256 currentAllowance = s_allowances[_from][msg.sender];
        if (currentAllowance < _amount) {
            revert ERC20__InsufficientAllowance(currentAllowance, _amount);
        }

        // Decrease allowance before transfer (CEI)
        s_allowances[_from][msg.sender] = currentAllowance - _amount;

        _transfer(_from, _to, _amount);
        return true;
    }

    // ─── Owner functions ───────────────────────────────────────────────────────

    /// @notice Mint new tokens to `_to`. Only callable by the owner.
    /// @param _to     Recipient of new tokens.
    /// @param _amount Number of tokens to mint.
    function mint(address _to, uint256 _amount) external {
        if (msg.sender != i_owner) revert ERC20__NotOwner();
        _mint(_to, _amount);
    }

    /// @notice Burn tokens from `_from`. Only callable by the owner.
    /// @param _from   Address to burn from.
    /// @param _amount Number of tokens to burn.
    function burn(address _from, uint256 _amount) external {
        if (msg.sender != i_owner) revert ERC20__NotOwner();
        _burn(_from, _amount);
    }

    // ─── View helpers ──────────────────────────────────────────────────────────

    function name() external view returns (string memory) {
        return s_name;
    }

    function symbol() external view returns (string memory) {
        return s_symbol;
    }

    function decimals() external view returns (uint8) {
        return i_decimals;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    // ─── Internal ──────────────────────────────────────────────────────────────

    /// @dev Core transfer logic shared by transfer() and transferFrom().
    function _transfer(address _from, address _to, uint256 _amount) internal {
        if (_to == address(0)) revert ERC20__TransferToZeroAddress();

        uint256 fromBalance = s_balances[_from];
        if (fromBalance < _amount) {
            revert ERC20__InsufficientBalance(fromBalance, _amount);
        }

        console2.log("ERC20.transfer: from=%s to=%s amount=%d", _from, _to, _amount);

        s_balances[_from] = fromBalance - _amount;
        s_balances[_to] += _amount;

        emit Transfer(_from, _to, _amount);
    }

    /// @dev Mint `_amount` tokens to `_to`, increasing total supply.
    function _mint(address _to, uint256 _amount) internal {
        if (_to == address(0)) revert ERC20__MintToZeroAddress();
        s_totalSupply += _amount;
        s_balances[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    /// @dev Burn `_amount` tokens from `_from`, decreasing total supply.
    function _burn(address _from, uint256 _amount) internal {
        if (s_balances[_from] < _amount) revert ERC20__BurnExceedsBalance();
        s_balances[_from] -= _amount;
        s_totalSupply -= _amount;
        emit Transfer(_from, address(0), _amount);
    }
}
