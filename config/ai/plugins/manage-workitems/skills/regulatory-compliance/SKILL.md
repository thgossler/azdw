---
name: regulatory-compliance
description: >
  Provides regulatory compliance knowledge for software products across
  deployment contexts (on-prem, cloud, US/EU/China). Covers GDPR,
  CCPA/CPRA, China PIPL, MLPS 2.0, EU AI Act, ISO 27001, NIS 2, SOC 2, BSI C5,
  Xinchuang (信创/ITAI), SM2/SM3/SM4 cryptographic standards, and cross-region
  deployment constraints. Use when the user mentions regulatory, compliance,
  GDPR, CCPA, CPRA, PIPL, China, MLPS, Xinchuang, ITAI, SM2, SM3, SM4, deployment
  scenario, on-prem vs cloud, NIS 2, SOC 2, BSI C5, EU AI Act, cryptography,
  CII, regulatory requirements, or cross-region deployment.
---

# Regulatory Compliance for Software Products

## Overview

This skill provides detailed regulatory knowledge for software products
deployed across multiple markets and deployment models. It covers data
protection, cybersecurity, AI governance, cryptography requirements, and
China-specific technology indigenization constraints.

## When to Use This Skill

Use this knowledge when:

- Advising on regulatory requirements for a specific deployment scenario
- Answering questions about compliance standards (GDPR, CCPA/CPRA, ISO 27001, etc.)
- Helping architect solutions that must meet multi-region regulatory constraints
- Evaluating deployment model trade-offs (on-prem vs cloud, US/EU/China)
- Assessing China-specific requirements (Xinchuang/ITAI, SM2/SM3/SM4, MLPS 2.0)
- Identifying conflicts between regulatory domains
- Making architectural decisions with regulatory implications

## Quick Reference: Key Regulatory Domains

| Domain | Key Standards | Scope |
| ------- | ------------ | ----- |
| AI governance | EU AI Act 2024/1689 | High-risk AI systems classification and obligations |
| Data protection | GDPR, US state privacy laws (CCPA/CPRA), China PIPL | Personal data processing and cross-border transfers |
| Cybersecurity | ISO 27001, NIS 2, SOC 2, BSI C5, China MLPS 2.0 | Information security controls |
| Cryptography (China CII) | SM2, SM3, SM4, Cryptography Law | Mandatory Chinese crypto for critical infrastructure |
| Technology indigenization | Xinchuang (信创/ITAI), Document 79 | Domestic technology requirements for CII sectors |

## Deployment Scenarios

The regulatory profile depends on the deployment context. Six scenarios are
defined, from single-region on-prem to multi-region hybrid:

1. **On-Prem (EU/US/Global)** — data protection + cybersecurity baseline
2. **On-Prem (China)** — adds PIPL, MLPS 2.0, SM2/SM3/SM4, Xinchuang/ITAI
3. **Cloud (EU)** — adds NIS 2, BSI C5, SOC 2, EU AI Act
4. **Cloud (US/Global)** — adds SOC 2, US state privacy laws
5. **Cloud (China)** — adds MLPS 2.0, SM2/SM3/SM4, Xinchuang/ITAI, 21Vianet constraints
6. **All of the Above** — cumulative superset with conflict resolution

## Detailed Regulatory Matrix

For the full deployment-context matrix including:

- Per-scenario regulatory requirements with specific standard versions
- Architecture constraints and design decisions per scenario
- Cross-domain conflict analysis
- China-specific deep dives (Xinchuang/ITAI on-prem vs cloud enforcement, Azure
  China 21Vianet viability assessment)
- Key architectural decisions (crypto-agile architecture, Xinchuang/ITAI supply-chain)
- Product Management checklist

**Read the full reference document:**
[regulatory-requirements.md](regulatory-requirements.md)

> **Instructions for AI agents**: When you need the detailed regulatory matrix,
> read the `regulatory-requirements.md` file in this skill's directory. The file
> contains the complete deployment-context matrix with all scenarios, conflicts,
> and architectural constraints. Only load it when the user's question requires
> specific regulatory details — the quick reference above is sufficient for
> general guidance.
