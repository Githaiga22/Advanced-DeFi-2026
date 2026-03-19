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
