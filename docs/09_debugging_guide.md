# 09 — Debugging Guide

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## 1. Reading Compiler Errors

### "Undeclared identifier"
```
Error: Undeclared identifier.
   --> src/MyContract.sol:42:9
```
The variable or function doesn't exist at that scope. Check spelling, imports, and visibility.

### "Function overloading / no matching overload"
Usually a type mismatch in function arguments. Check `uint256` vs `int256`, `address payable` vs `address`.

### "Stack too deep"
More than 16 local variables in scope. Extract logic into internal functions.

### "Overriding function changes state mutability"
You're adding/removing `view` or `pure` in an override. Match the base function exactly.

---

## 2. Reading -vvvv Trace Output

Run your test with full traces:
```bash
forge test --match-test test_MyTest -vvvv
```

### Annotated Example
```
[PASS] test_ReentrancyDrainsBank()
Traces:
  [123456] ReentrancyExploitTest::test_ReentrancyDrainsBank()
    ├─ [500] VulnerableBank::deposit{value: 3000000000000000000}()  ← Alice deposits 3 ETH
    │   └─ emit Deposited(user: alice, amount: 3000000000000000000)
    ├─ [500] VulnerableBank::deposit{value: 2000000000000000000}()  ← Bob deposits 2 ETH
    ├─ [12000] ReentrancyAttacker::attack{value: 1000000000000000000}()
    │   ├─ [500] VulnerableBank::deposit{value: 1000000000000000000}()  ← Attacker deposits 1 ETH
    │   └─ [8000] VulnerableBank::withdraw()                            ← First withdrawal
    │       ├─ [receive] ReentrancyAttacker::receive()                  ← Re-entry 1
    │       │   └─ [7000] VulnerableBank::withdraw()                    ← Re-entry 2
    │       │       └─ [receive] ReentrancyAttacker::receive()          ← ...keeps going
```

**Key signals:**
- `[REVERT]` — call reverted (look at the revert reason below)
- `[STATICCALL]` — view function call
- `{value: X}` — ETH transferred
- `emit EventName(...)` — event emitted

---

## 3. Fuzz Test Failures

When a fuzz test fails, Foundry shows the counterexample:
```
[FAIL: assertion failed] testFuzz_Transfer(uint256) (runs: 47, μ: 25000, ~: 23000)
Counterexample:
    args: [115792089237316195423570985008687907853269984665640564039457584007913129639935]
```
The counterexample is the exact input that caused failure. Use `vm.assume()` to exclude invalid inputs:
```solidity
function testFuzz_Transfer(uint256 _amount) public {
    vm.assume(_amount > 0);
    vm.assume(_amount <= token.balanceOf(owner));
    ...
}
```

Or use `bound()` for range restriction:
```solidity
_amount = bound(_amount, 1, token.balanceOf(owner));
```

---

## 4. console2.log Debugging

`console2.log` only runs inside the Forge test environment (no-op in production).

```solidity
import {console2} from "forge-std/console2.sol";

// Supported signatures:
console2.log("message");
console2.log("uint value:", myUint);
console2.log("address:", myAddress);
console2.log("bool:", myBool);
console2.log("Before: %d, After: %d", before, after);  // formatted
```

Logs appear in test output when using `-vv` or higher verbosity.

---

## 5. Gas Analysis

```bash
# See gas used per function
forge test --gas-report

# Snapshot current gas costs
forge snapshot

# Check if any gas costs changed
forge snapshot --check
```

Example gas report:
```
| Contract     | Function  | min  | avg  | median | max  | # calls |
|---|---|---|---|---|---|---|
| SimpleVault  | deposit   | 5421 | 5421 | 5421   | 5421 | 5       |
| SimpleVault  | withdraw  | 3210 | 3210 | 3210   | 3210 | 3       |
```

---

## 6. Storage Layout Inspection

```bash
forge inspect src/01_basics/SimpleStorage.sol:SimpleStorage storageLayout
```

Output:
```json
{
  "storage": [
    {
      "label": "s_storedValues",
      "slot": "0",
      "type": "mapping(address => uint256)"
    }
  ]
}
```

Use this when debugging proxy contracts, upgrades, or slot collision attacks.

---

## 7. Replaying Historical Transactions

```bash
# Replay any transaction from mainnet (requires archive node)
cast run <TX_HASH> --rpc-url $MAINNET_RPC --verbose
```

This gives you a full trace of what happened in any historical transaction — incredibly useful for studying real exploits.

---

## 8. Common Revert Reasons Table

| Revert Message | Likely Cause |
|---|---|
| `"not owner"` | Calling a privileged function without owner role |
| `"transfer failed"` | ETH transfer to a contract without `receive()` |
| `"reentrant call"` | Reentrancy guard triggered |
| `"arithmetic overflow"` | Subtraction underflow or addition overflow |
| `"insufficient balance"` | Trying to transfer/burn more than balance |
| `"already initialized"` | Calling `initialize()` twice on a proxy |
| `EvmError: Revert` (no message) | Bare `revert()`, failed assertion, or out-of-gas |

---

## 9. Useful Cheatcodes Quick Reference

```solidity
// Time manipulation
vm.warp(block.timestamp + 1 days);

// Block number
vm.roll(block.number + 100);

// Impersonate any address
vm.prank(alice);          // next call only
vm.startPrank(alice);     // all calls until stopPrank
vm.stopPrank();

// Fund any address
vm.deal(alice, 10 ether);

// Set storage directly
vm.store(address(contract), bytes32(slot), bytes32(value));

// Expect a revert
vm.expectRevert("error message");
vm.expectRevert(MyContract.MyError.selector);

// Expect an event
vm.expectEmit(true, true, false, true);
emit MyEvent(arg1, arg2);

// Label addresses (shows in traces)
vm.label(alice, "alice");
```
