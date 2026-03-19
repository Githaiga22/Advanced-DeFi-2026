// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FundMe} from "../../src/01_basics/FundMe.sol";

/// @title FundMeTest
/// @author Allan Robinson
/// @notice Tests for FundMe — covers funding, withdrawal, access control, receive/fallback.
contract FundMeTest is Test {
    FundMe public fundMe;

    address public owner = makeAddr("owner");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 public constant MINIMUM_ETH = 0.01 ether;
    uint256 public constant FUND_AMOUNT = 0.5 ether;

    function setUp() public {
        vm.prank(owner);
        fundMe = new FundMe();

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    // ─── fund() ────────────────────────────────────────────────────────────────

    function test_FundSucceeds() public {
        vm.prank(alice);
        fundMe.fund{value: FUND_AMOUNT}();
        assertEq(fundMe.getAmountFunded(alice), FUND_AMOUNT);
    }

    function test_FundEmitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit FundMe.Funded(alice, FUND_AMOUNT);
        fundMe.fund{value: FUND_AMOUNT}();
    }

    function test_FundRevertsIfBelowMinimum() public {
        uint256 tooLow = MINIMUM_ETH - 1;
        vm.prank(alice);
