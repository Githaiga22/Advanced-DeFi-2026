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
