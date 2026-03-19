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
