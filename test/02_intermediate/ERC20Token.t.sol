// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20Token} from "../../src/02_intermediate/ERC20Token.sol";

/// @title ERC20TokenTest
/// @author Allan Robinson
/// @notice Full test suite for the hand-rolled ERC20Token.
contract ERC20TokenTest is Test {
    ERC20Token public token;

    address public owner = makeAddr("owner");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 public constant INITIAL_SUPPLY = 1_000_000; // whole tokens
    uint256 public constant DECIMALS_FACTOR = 1e18;

    function setUp() public {
        vm.prank(owner);
        token = new ERC20Token("Cyfrin Token", "CFN", 18, INITIAL_SUPPLY);
    }

    // ─── Metadata ──────────────────────────────────────────────────────────────

    function test_Metadata() public view {
        assertEq(token.name(), "Cyfrin Token");
        assertEq(token.symbol(), "CFN");
        assertEq(token.decimals(), 18);
    }

    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY * DECIMALS_FACTOR);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY * DECIMALS_FACTOR);
    }

    // ─── transfer() ────────────────────────────────────────────────────────────

    function test_Transfer() public {
        uint256 amount = 100 * DECIMALS_FACTOR;
        vm.prank(owner);
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(owner), (INITIAL_SUPPLY * DECIMALS_FACTOR) - amount);
    }

    function test_TransferEmitsEvent() public {
        uint256 amount = 50 * DECIMALS_FACTOR;
        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit ERC20Token.Transfer(owner, alice, amount);
        token.transfer(alice, amount);
    }

    function test_TransferRevertsInsufficientBalance() public {
        uint256 tooMuch = INITIAL_SUPPLY * DECIMALS_FACTOR + 1;
        vm.prank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(ERC20Token.ERC20__InsufficientBalance.selector, INITIAL_SUPPLY * DECIMALS_FACTOR, tooMuch)
        );
        token.transfer(alice, tooMuch);
    }

    function test_TransferRevertsToZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(ERC20Token.ERC20__TransferToZeroAddress.selector);
        token.transfer(address(0), 1);
    }

    // ─── approve() + transferFrom() ────────────────────────────────────────────

    function test_ApproveAndTransferFrom() public {
        uint256 amount = 200 * DECIMALS_FACTOR;
        vm.prank(owner);
        token.approve(alice, amount);

        assertEq(token.allowance(owner, alice), amount);

        vm.prank(alice);
        token.transferFrom(owner, bob, amount);

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.allowance(owner, alice), 0);
    }
