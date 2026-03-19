# 03 — Access Control Vulnerabilities

**Author:** Allan Robinson
**Created:** 2026-03-19 | **Last Updated:** 2026-03-19

---

## The #1 Finding Category

Access control is the **most common** vulnerability category in competitive audits. It covers:

- Using `tx.origin` instead of `msg.sender`
- Missing `onlyOwner` / role checks
- Incorrect ownership transfer logic
- Unprotected `selfdestruct` / `initialize()`
- Public vs external vs internal visibility mistakes

---

## tx.origin vs msg.sender

| Property | `msg.sender` | `tx.origin` |
|---|---|---|
| What it is | Immediate caller (EOA or contract) | The original EOA that started the tx |
| Safe for auth? | **Yes** | **No — phishing attack possible** |

```
EOA (Alice) → MaliciousContract → VulnerableContract
                                   tx.origin = Alice ← passes check!
                                   msg.sender = MaliciousContract ← correct caller
```

---

## Vulnerable Code

```solidity
// ❌ VULNERABLE — tx.origin auth
modifier onlyOwner() {
    require(tx.origin == owner, "not owner"); // ← phishable
    _;
}

function destroy() external onlyOwner {
    selfdestruct(payable(owner)); // ← callable via phishing
}
```

---

## The Phishing Attack

```solidity
// Attacker deploys this contract and tricks the owner into calling it
contract Phisher {
    VulnerableAccessControl public target;
    address public attacker;

    constructor(address _target) {
        target = VulnerableAccessControl(_target);
        attacker = msg.sender;
    }

    // Owner calls this (maybe via a misleading UI)
    function claimFreeTokens() external {
        // tx.origin == owner (they called this)
        // msg.sender == address(this)
        // The target's check passes because tx.origin == owner
        target.destroy(); // ← drain + destroy target!
    }
}
```

---

## Fixed Code

```solidity
// ✅ FIXED — use msg.sender, never tx.origin for auth
modifier onlyOwner() {
    require(msg.sender == owner, "not owner"); // ← phishing-safe
    _;
}
```

---

## Ownership Transfer Best Practice

```solidity
// ❌ Dangerous — one-step transfer (typo = permanent loss)
function transferOwnership(address _new) external onlyOwner {
    owner = _new;
}

// ✅ Safe — two-step transfer (new owner must accept)
function transferOwnership(address _pending) external onlyOwner {
    pendingOwner = _pending;
}

function acceptOwnership() external {
    require(msg.sender == pendingOwner, "not pending owner"); // ← msg.sender!
    owner = pendingOwner;
    pendingOwner = address(0);
}
```

---

## Unprotected selfdestruct

Never leave `selfdestruct` in a reachable path. If you must include it:
- Guard with `msg.sender == owner`
- Add a timelock or multisig requirement
- Consider removing it entirely — `selfdestruct` behaviour is changing in EIP-6780

---

## Key Audit Checklist

- [ ] Every privileged function uses `msg.sender`, not `tx.origin`
- [ ] `initialize()` functions are protected against re-initialization
- [ ] Ownership transfer is two-step (offer + accept)
- [ ] `selfdestruct` is either absent or heavily guarded
- [ ] Role-based access uses a well-audited library (OpenZeppelin AccessControl)
