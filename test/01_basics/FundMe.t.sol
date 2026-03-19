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
        vm.expectRevert(abi.encodeWithSelector(FundMe.FundMe__BelowMinimum.selector, tooLow, MINIMUM_ETH));
        fundMe.fund{value: tooLow}();
    }

    function test_FundAccumulatesBalance() public {
        vm.startPrank(alice);
        fundMe.fund{value: FUND_AMOUNT}();
        fundMe.fund{value: FUND_AMOUNT}();
        vm.stopPrank();
        assertEq(fundMe.getAmountFunded(alice), FUND_AMOUNT * 2);
    }

    function test_MultipleFundersTracked() public {
        vm.prank(alice);
        fundMe.fund{value: FUND_AMOUNT}();

        vm.prank(bob);
        fundMe.fund{value: FUND_AMOUNT}();

        address[] memory funders = fundMe.getFunders();
        assertEq(funders.length, 2);
        assertEq(funders[0], alice);
        assertEq(funders[1], bob);
    }

    // ─── receive() / fallback() ────────────────────────────────────────────────

    function test_ReceiveRoutesToFund() public {
        vm.prank(alice);
        (bool ok,) = address(fundMe).call{value: FUND_AMOUNT}("");
        assertTrue(ok);
        assertEq(fundMe.getAmountFunded(alice), FUND_AMOUNT);
    }

    function test_FallbackRoutesToFund() public {
        vm.prank(alice);
        (bool ok,) = address(fundMe).call{value: FUND_AMOUNT}(abi.encodePacked("someData"));
        assertTrue(ok);
        assertEq(fundMe.getAmountFunded(alice), FUND_AMOUNT);
    }

    // ─── withdraw() ────────────────────────────────────────────────────────────

    function test_WithdrawByOwner() public {
        vm.prank(alice);
        fundMe.fund{value: FUND_AMOUNT}();

        uint256 ownerBefore = owner.balance;

        vm.prank(owner);
        fundMe.withdraw();

        assertEq(owner.balance, ownerBefore + FUND_AMOUNT);
        assertEq(address(fundMe).balance, 0);
    }

    function test_WithdrawResetsFunderRecords() public {
        vm.prank(alice);
        fundMe.fund{value: FUND_AMOUNT}();

        vm.prank(owner);
        fundMe.withdraw();

        assertEq(fundMe.getAmountFunded(alice), 0);
        assertEq(fundMe.getFunders().length, 0);
    }

    function test_WithdrawRevertsForNonOwner() public {
        vm.prank(alice);
        fundMe.fund{value: FUND_AMOUNT}();

        vm.prank(alice);
        vm.expectRevert(FundMe.FundMe__NotOwner.selector);
        fundMe.withdraw();
    }

    function test_WithdrawRevertsIfEmpty() public {
        vm.prank(owner);
        vm.expectRevert(FundMe.FundMe__NothingToWithdraw.selector);
        fundMe.withdraw();
    }

    // ─── Fuzz ──────────────────────────────────────────────────────────────────

    function testFuzz_FundWithVariousAmounts(uint256 _amount) public {
        vm.assume(_amount >= MINIMUM_ETH && _amount <= 5 ether);
        vm.deal(alice, _amount);
        vm.prank(alice);
        fundMe.fund{value: _amount}();
        assertEq(fundMe.getAmountFunded(alice), _amount);
    }
}
