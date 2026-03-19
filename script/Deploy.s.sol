// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/01_basics/SimpleStorage.sol";
import {FundMe} from "../src/01_basics/FundMe.sol";
import {ERC20Token} from "../src/02_intermediate/ERC20Token.sol";
import {SimpleVault} from "../src/02_intermediate/SimpleVault.sol";

/// @title Deploy
/// @author Allan Robinson
/// @notice Deployment script for all learning modules.
///         Run on a local Anvil node:
///           anvil
///           forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast -vvvv
///
///         Or dry-run (no broadcast):
///           forge script script/Deploy.s.sol -vvvv
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("=== Allan Robinson - Smart Contract Auditing Deployment ===");
        console2.log("Deployer:   ", deployer);
        console2.log("Chain ID:   ", block.chainid);
        console2.log("Block:      ", block.number);

        vm.startBroadcast(deployerPrivateKey);

        // ── Module 1: Basics ────────────────────────────────────────────────────
        SimpleStorage simpleStorage = new SimpleStorage();
