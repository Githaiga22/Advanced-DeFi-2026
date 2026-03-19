// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SimpleStorage} from "../../src/01_basics/SimpleStorage.sol";

/// @title SimpleStorageTest
/// @author Allan Robinson
/// @notice Tests for SimpleStorage — covers store, retrieve, withdraw, access control.
contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage;

    address public owner = makeAddr("owner");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        vm.prank(owner);
        simpleStorage = new SimpleStorage();
    }

    // ─── store() ───────────────────────────────────────────────────────────────

    function test_StoreValue() public {
        vm.prank(alice);
        simpleStorage.store(42);
        assertEq(simpleStorage.retrieve(alice), 42);
    }

    function test_StoreEmitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit SimpleStorage.StoredValueUpdated(alice, 0, 100);
        simpleStorage.store(100);
    }

    function test_StoreRevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(SimpleStorage.SimpleStorage__ZeroValue.selector);
        simpleStorage.store(0);
    }

    function test_StoreUpdatesOldValue() public {
        vm.startPrank(alice);
        simpleStorage.store(10);
        simpleStorage.store(20);
        vm.stopPrank();
        assertEq(simpleStorage.retrieve(alice), 20);
    }

    function test_UsersHaveIndependentValues() public {
        vm.prank(alice);
        simpleStorage.store(111);

        vm.prank(bob);
        simpleStorage.store(222);

        assertEq(simpleStorage.retrieve(alice), 111);
        assertEq(simpleStorage.retrieve(bob), 222);
    }

    // ─── retrieve() ────────────────────────────────────────────────────────────

    function test_RetrieveDefaultIsZero() public view {
        assertEq(simpleStorage.retrieve(alice), 0);
    }

