# Bug Bounty Challenges

**Author:** Allan Robinson
**Purpose:** Practice finding real vulnerabilities in production-looking contracts — just like CodeHawks, Sherlock, and Immunefi.

---

## How It Works

Each challenge contract is written to look like real production code — full NatSpec, clean formatting, no obvious red flags. Hidden bugs range from 1 (easy) to 3+ (hard).

### Your workflow:
1. **Read the contract** carefully — treat it like a real audit.
2. **Write up your findings** using the report format below.
3. **Paste your report** in the chat and it will be scored.
4. **Optionally write a PoC exploit test** for bonus points.

---

## Scoring System

| Finding Type | Points |
|---|---|
| Critical (funds directly at risk) | 100 pts |
| High (logic error, significant impact) | 75 pts |
| Medium (access control, limited impact) | 50 pts |
| Low (best practice violation) | 25 pts |
| Informational (gas, style) | 10 pts |

**Bonus:** +50 points for each working PoC exploit test (`forge test` passes).

---

## Finding Report Template
