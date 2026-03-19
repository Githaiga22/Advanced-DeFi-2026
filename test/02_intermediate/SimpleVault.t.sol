// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SimpleVault} from "../../src/02_intermediate/SimpleVault.sol";

/// @title SimpleVaultTest
/// @author Allan Robinson
/// @notice Tests for SimpleVault — deposit, withdraw, share accounting, reentrancy guard.
contract SimpleVaultTest is Test {
    SimpleVault public vault;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        vault = new SimpleVault();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    // ─── deposit() ─────────────────────────────────────────────────────────────

    function test_DepositReceivesShares() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
        assertEq(vault.sharesOf(alice), 1 ether);
    }

    function test_DepositEmitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, false);
        emit SimpleVault.Deposited(alice, 1 ether, 1 ether);
        vault.deposit{value: 1 ether}();
    }

    function test_DepositRevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(SimpleVault.SimpleVault__ZeroDeposit.selector);
        vault.deposit{value: 0}();
    }

    function test_TwoDepositorsGetProportionalShares() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        vm.prank(bob);
        vault.deposit{value: 1 ether}();

        assertEq(vault.sharesOf(alice), vault.sharesOf(bob));
    }

    // ─── withdraw() ────────────────────────────────────────────────────────────

    function test_WithdrawReturnsETH() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        uint256 shares = vault.sharesOf(alice);
        uint256 aliceBefore = alice.balance;

        vm.prank(alice);
        vault.withdraw(shares);

        assertEq(alice.balance, aliceBefore + 1 ether);
        assertEq(vault.sharesOf(alice), 0);
    }

    function test_WithdrawRevertsOnZeroShares() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert(SimpleVault.SimpleVault__ZeroShares.selector);
        vault.withdraw(0);
    }

    function test_WithdrawRevertsOnInsufficientShares() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        uint256 shares = vault.sharesOf(alice);
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(SimpleVault.SimpleVault__InsufficientShares.selector, shares, shares + 1)
        );
        vault.withdraw(shares + 1);
    }

    // ─── Share accounting ──────────────────────────────────────────────────────

    function test_ShareValueGrowsWithYield() public {
        // Alice seeds the vault
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        // Simulate yield: send 1 ETH directly to vault
        vm.deal(address(vault), address(vault).balance + 1 ether);

        // Bob deposits 1 ETH — should receive fewer shares than Alice since vault grew
        vm.prank(bob);
        vault.deposit{value: 1 ether}();

        assertLt(vault.sharesOf(bob), vault.sharesOf(alice));
    }

    // ─── Reentrancy guard ──────────────────────────────────────────────────────

    function test_ReentrancyGuardBlocks() public {
        // Deploy a malicious receiver that tries to re-enter withdraw
        MaliciousReceiver attacker = new MaliciousReceiver(vault);
