# Regulatory Requirements by Deployment Context

> This file provides the detailed regulatory breakdown per deployment scenario.
> Product Management must specify the target markets for each software
> product/service, which determines which regulatory profile applies.
> Referenced from the `regulatory-compliance` skill ([SKILL.md](SKILL.md))
> and the MCP tool `azdw_GetRegulatoryRequirements`.

## How to Use This Document

Each product/service must declare its **deployment context** (one or more of the
scenarios below). The applicable regulations are cumulative: a product targeting
"Cloud (EU) + Cloud (US/Global)" must satisfy both columns. The final section
("All of the Above") describes the most restrictive superset.

---

## Applicable Standards (Reference Versions)

| Abbreviation | Full Name | Version |
| ---------- | --------- | --------- |
| EU AI Act | Artificial Intelligence Act | Regulation 2024/1689 |
| GDPR | General Data Protection Regulation | EU 2016/679 |
| Europrivacy | European Data Protection Seal | Art. 42/43 GDPR |
| CCPA | California Consumer Privacy Act | Cal. Civ. Code §§ 1798.100–1798.199.100 |
| CPRA | California Privacy Rights Act (amends CCPA) | Proposition 24 (2020), effective 2023-01-01 |
| ISO 27001 | Information security management systems | ISO/IEC 27001:2022 |
| NIS 2 | Network and Information Security Directive | EU 2022/2555 |
| SOC 2 | Service Organization Control | AICPA 2017 TSC |
| BSI C5 | Cloud Computing Compliance Criteria Catalogue | C5:2020 |
| China MLPS 2.0 | Multi-Level Protection Scheme | GB/T 22239-2019 (Level III) |
| China Cryptography Law | Cryptography Law of the P.R.C. | Effective 2020-01-01 |
| China CII Crypto Provisions | CAC Provisions on Commercial Encryption in CII | Effective 2025-08-01 |
| SM2 | Public Key Cryptographic Algorithms (ECC-based) | GB/T 32918-2016 |
| SM3 | Cryptographic Hash Algorithm | GB/T 32905-2016 |
| SM4 | Block Cipher Algorithm | GB/T 32907-2016 |
| Xinchuang (信创) | IT Application Innovation (ITAI) — technology indigenization programme | Document 79 (Sept 2022); Phase 2 target ~2025 |
| China PIPL | Personal Information Protection Law | Effective 2021-11-01 |
| China DSL | Data Security Law | Effective 2021-09-01 |
| China CSL | Cybersecurity Law | Effective 2017-06-01, amended 2026-01-01 |

---

## Scenario 1 — On-Prem Only (US/EU)

**Deployment**: Software installed and operated at customer premises in the US or EU. No cloud connectivity for sensitive data.

### Applicable Regulations

| Domain | Standards | Key Obligations |
| ---------- | ---------- | ---------- |
| AI (if applicable) | EU AI Act | High-risk classification for AI systems; risk management; training data governance; transparency obligations (by Aug 2026). |
| Data protection (EU) | GDPR, Europrivacy | Data processing agreements with customers; privacy-by-design; DPIA where required. Even on-prem, vendor may access data for maintenance/support. |
| Data protection (US) | CCPA/CPRA, US state privacy laws | Consumer privacy rights (access, deletion, opt-out of sale); data processing agreements; breach notification per state law (varies, typically 30–60 days). |
| Cybersecurity | ISO 27001 | ISMS for development and support operations. |
| Cybersecurity (EU) | NIS 2 | Incident reporting (24h early warning, 72h full notification) if vendor qualifies as essential/important entity. |

### Architecture Constraints

- Customer controls the infrastructure; vendor must provide hardening guides.
- Software updates delivered as validated release packages (not continuous deployment).
- Audit trails must be self-contained within the installed product.

---

## Scenario 2 — On-Prem Only (China)

**Deployment**: Software installed and operated at customer premises in China. No cloud connectivity.

### Applicable Regulations

| Domain | Standards | Key Obligations |
| ---------- | ---------- | ---------- |
| Cybersecurity | MLPS 2.0 Level III (GB/T 22239-2019) | Government-supervised security assessment; may include source code review. |
| Cryptography | China Cryptography Law, CII Crypto Provisions, SM2/SM3/SM4 | CII operators **must** use State Cryptography Administration (SCA)-certified commercial cryptography. All encryption, hashing, and digital signatures must use state-approved algorithms (SM2 for public key, SM3 for hashing, SM4 for symmetric encryption). Foreign algorithms (AES, RSA, SHA) are **not accepted** as primary cryptographic mechanisms for CII in China. Products must pass commercial encryption security assessments at planning, construction, and operation stages. |
| Technology indigenization | Xinchuang (信创/ITAI) — Document 79 | CII sectors are priority targets. Software components used in CII must be sourced from **domestic Chinese vendors or open-source projects**; foreign (especially US-origin) proprietary software, hardware, and operating systems are to be replaced. Affects OS, databases, middleware, office systems, and business management software. Products targeting the Chinese market must evaluate their dependency tree for Xinchuang/ITAI compliance. |
| Data protection | China PIPL, China DSL, China CSL (amended 2026) | Personal information must remain in China unless security assessment, SCCs, or PIP certification obtained for cross-border transfer. Separate consent required for any outbound transfer. CSL 2026 amendment strengthens enforcement, expands CII regulatory reach, and tightens AI/cloud oversight. |

### Architecture Constraints

- All sensitive data and logs must remain within China (data localization).
- Source code or technical documentation may be subject to government review.
- No telemetry or diagnostic data may leave Chinese borders without assessment.
- **Cryptography**: All data-at-rest encryption must use SM4 (not AES). All digital signatures and key exchange must use SM2 (not RSA/ECDSA). All hashing must use SM3 (not SHA-256). TLS connections should use SM2-based certificate chains (GM/T 0024 / TLCP protocol). SCA certification of cryptographic modules is mandatory.
- **Xinchuang/ITAI**: Evaluate and document the full software supply chain (OS, database, middleware, runtime, libraries). Where products are deployed in Chinese CII, non-Chinese proprietary components may need to be replaced with domestic or open-source alternatives. This includes technology runtimes — consider whether a domestically supported runtime or open-source alternative is required.

### Conflict with US/EU On-Prem

- MLPS 2.0 government review requirements may conflict with IP protection assumptions in US/EU markets.
- China PIPL's data localization is stricter than GDPR's adequacy-based transfer model.
- **SM2/SM3/SM4 vs AES/RSA/SHA**: Products must maintain dual cryptographic stacks — Western standards (AES-256, RSA/ECC, SHA-256) for US/EU and Chinese national standards (SM4, SM2, SM3) for China. This creates significant engineering overhead and requires crypto-agile architecture.
- **Xinchuang/ITAI vs global supply chain**: A product built on a Western technology stack for US/EU markets may need a fundamentally different technology base for the Chinese market, potentially requiring parallel development tracks or a modular architecture that can swap underlying platform components.

> ### Xinchuang/ITAI: On-Prem vs Cloud — Enforcement Differences
>
> Xinchuang/ITAI does not formally distinguish between on-prem and cloud deployment models — its scope is defined by **sector and entity type** (government, SOEs, CII operators). However, practical enforcement differs:
>
> | Aspect | On-Prem (installed software) | Cloud (SaaS/PaaS/IaaS) |
> | --- | --- | --- |
> | **Timeline** | Phase 2 (~2025): SOE/CII sectors. Core office systems by ~2025; business management software by 2027; R&D systems "flexible." | Cloud platforms are part of Phase 3 (broader market, 2027–2035), but CII cloud infrastructure is already under scrutiny. |
> | **Enforcement mechanism** | Direct procurement ban — SOEs and CII operators replace installed foreign software via purchasing decisions controlled by SASAC/MIIT. | Indirect: a 2017 policy requires cloud services in China to be **operated by Chinese companies**. Foreign clouds (Azure, AWS) partner with domestic entities (21Vianet, Sinnet). This arrangement has been accepted so far but is not a formal Xinchuang/ITAI exemption. |
> | **Current pressure** | **Higher and earlier** — CII organizations procuring on-prem systems face direct scrutiny. Foreign OS, databases, and middleware are actively being replaced with domestic alternatives. | **Lower but tightening** — the 21Vianet model is tolerated today, but the 2026 CSL amendment explicitly references "Xinchuang/ITAI domestic IT stack expectations" for cloud-hosted CII platforms. |
> | **Crypto requirements** | SM2/SM3/SM4 mandatory for CII from Aug 2025 — no deployment-model distinction. | Same crypto law applies; the cloud provider's infrastructure must also use SCA-certified modules at the platform level. |
> | **Practical implication** | Products installed in CII data centres face **immediate** Xinchuang/ITAI compliance pressure. | Cloud-hosted SaaS delivered via 21Vianet-operated Azure has a **temporary accommodation** but should be treated as a narrowing window, not a permanent exemption. |
>
> **Recommendation**: Do not assume cloud delivery avoids Xinchuang/ITAI. Plan for both deployment models to require Xinchuang/ITAI-compliant supply chains by 2027–2030 at the latest for CII sectors.

---

## Scenario 3 — Cloud (US/Global)

**Deployment**: Cloud-hosted SaaS/PaaS on Azure (US regions), serving US and non-EU/non-China markets.

### Applicable Regulations

| Domain | Standards | Key Obligations |
| ---------- | ---------- | ---------- |
| AI (if applicable) | EU AI Act (if also EU-marketed) | Only if product is also placed on EU market. |
| Data protection (US) | CCPA/CPRA, US state privacy laws | Consumer privacy rights; data processing agreements with cloud provider; encryption at rest and in transit; access logging. |
| Cybersecurity | ISO 27001, SOC 2 | ISMS for cloud operations; SOC 2 Type II report for customer assurance. |

### Architecture Constraints

- Audit trails must be immutable and accessible across the cloud stack (application + infrastructure).
- Multi-tenant isolation must be demonstrable for data protection and SOC 2.
- SBOM (Software Bill of Materials) increasingly expected by enterprise customers and regulatory bodies.

---

## Scenario 4 — Cloud (EU)

**Deployment**: Cloud-hosted SaaS/PaaS on Azure (EU regions), serving EU/EEA markets.

### Applicable Regulations

| Domain | Standards | Key Obligations |
| ---------- | ---------- | ---------- |
| AI (if applicable) | EU AI Act | High-risk AI obligations by Aug 2026: training data governance, bias assessment, explainability, human oversight, continuous performance monitoring. |
| Data protection | GDPR, Europrivacy | All personal data must be processed within EEA or under adequacy decision/SCCs. Azure EU Data Boundary applies. Right to erasure, data portability, DPIA required. |
| Cybersecurity | ISO 27001, NIS 2, BSI C5 | NIS 2 incident reporting timelines (24h/72h) stricter than ISO 27001. BSI C5 required for German cloud deployments. |

### Architecture Constraints

- Data residency: all PII must stay within EU Data Boundary — includes telemetry, logs, AI inference, and backup data.
- NIS 2 incident reporting (24h early warning) is stricter than most US state breach notification laws (30–60 days) — system must support rapid detection and notification.
- BSI C5 audit requirements add German-specific controls on top of ISO 27001/SOC 2.

### Conflict with Cloud (US/Global)

- GDPR restricts EU personal data from flowing to US regions (no blanket adequacy decision for US).
- US state privacy laws have no data residency requirement; GDPR does — a single global tenant cannot serve both without data boundary enforcement.
- NIS 2 notification timeline (24h) conflicts with US state breach notification windows (30–60 days) — the strictest applies, but different authorities must be notified via different channels.

---

## Scenario 5 — Cloud (China)

**Deployment**: Cloud-hosted on Azure China (operated by 21Vianet), serving the Chinese market.

### Applicable Regulations

| Domain | Standards | Key Obligations |
| ---------- | ---------- | ---------- |
| Cybersecurity | MLPS 2.0 Level III | Government-supervised assessment of the cloud deployment; penetration testing; may require source code access. |
| Cryptography | China Cryptography Law, CII Crypto Provisions, SM2/SM3/SM4 | Cloud infrastructure and application layer must use SCA-certified cryptographic modules. SM4 for encryption at rest and in transit, SM2 for key exchange and signatures, SM3 for hashing. Azure China (21Vianet) must provide SM-algorithm support at the platform level or the application must implement its own compliant crypto layer. |
| Technology indigenization | Xinchuang (信创/ITAI) | Cloud platform components (OS, database, middleware) are subject to Xinchuang/ITAI requirements when serving CII sectors. Azure China (21Vianet) operates under a Chinese entity, which partially satisfies the domestic-operator requirement, but the underlying software stack remains foreign-origin. Monitor for tightening enforcement. |
| Data protection | China PIPL, China DSL, China CSL (amended 2026) | **Strict data localization**: all personal information and "important data" must be stored and processed within China. Cross-border transfer requires CAC security assessment (mandatory for CIIO or large-volume PI processors), China SCCs, or PIP certification. |

### Architecture Constraints

- Azure China (21Vianet) is a **physically and logically separate cloud** from global Azure — no shared identity, no data replication to other regions.
- AI model training data collected in China cannot leave China without security assessment.
- Software updates must be deployed independently to the China environment; no global rollout possible.
- Government may require access to audit logs, source code, or encryption keys.
- **Cryptography**: Same SM2/SM3/SM4 requirements as on-prem China (see Scenario 2). Azure China platform services may not natively support SM algorithms for all services — application-layer SM-compliant crypto wrappers may be required.
- **Xinchuang/ITAI**: While 21Vianet operates the Azure China cloud, the underlying Microsoft stack may face increasing Xinchuang/ITAI scrutiny for CII sectors. Evaluate domestic cloud alternatives (Alibaba Cloud, Tencent Cloud, Huawei Cloud) as a contingency if Azure China becomes non-compliant for CII use.

### Conflict with Cloud (US/Global) and Cloud (EU)

- Data cannot flow between China and any other region without government-approved mechanisms.
- GDPR's adequacy framework and China PIPL's security assessment framework are **mutually incompatible** — there is no adequacy decision between EU and China.
- A single global cloud architecture is impossible; China requires a fully independent deployment.
- IP exposure risk: MLPS 2.0 government review + potential source code access conflicts with Western IP protection practices.
- **Cryptographic incompatibility**: SM2/SM3/SM4 (mandatory in China) vs AES/RSA/SHA (expected in US/EU). Cross-region data exchange, even if legally permitted, would require cryptographic re-encryption at the boundary.
- **Platform risk**: Xinchuang/ITAI policy may eventually disqualify Azure China (21Vianet) for CII if enforcement tightens to require fully domestic cloud stacks. This is a strategic risk requiring ongoing monitoring and contingency planning.

> ### Azure China (21Vianet) Viability for CII — Assessment
>
> **Status (as of March 2026): No official ban, but a growing de-facto barrier.**
>
> Azure China (21Vianet) is **not officially prohibited** for CII use. It holds:
> - **MLPS 2.0 Level 3** (DJCP) certification — assessed by an MPS-authorized organization per GB/T 22239-2019.
> - **Trusted Cloud Service (TCS)** evaluations — 10 TCS certifications under MIIT's OSCA framework.
> - **IRCS licence** (Internet Resource Collaboration Service) — obtained Aug 2017 per cloud service regulations.
>
> However, **multiple converging factors create a de-facto barrier** for CII deployments:
>
> | Factor | Detail | Severity |
> | --- | --- | --- |
> | **SM2/SM3/SM4 compliance gap** | Azure China has **no public documentation** confirming platform-level support for OSCCA/ShangMi algorithms (SM2, SM3, SM4). A Microsoft Q&A response redirects to "contact Azure China support." AWS, by contrast, has published ShangMi compliance documentation. The CAC CII Crypto Provisions (effective Aug 2025) **mandate** SCA-certified cryptography for all CII operators — including cloud providers serving them. | **High** — potential blocker for CII compliance |
> | **Xinchuang/ITAI procurement pressure** | CII organizations increasingly apply Xinchuang/ITAI domestic-stack preferences in procurement. IT infrastructure tenders are dominated by **domestic vendors**. Azure China is positioned for "corporate workloads and control plane" — not CII-facing services. | **High** — demand-side exclusion |
> | **Government procurement rules (Jan 2026)** | New rules emphasize "domestic product" classification based on domestic manufacturing and component sourcing. While they ban discrimination by company origin/ownership, they favour products with high domestic-component ratios. Azure's underlying stack is foreign-origin. | **Medium** — indirect, not a ban |
> | **CSL 2026 supply-chain review** | CIIOs face **stricter supply-chain security reviews**. Cloud providers serving CIIOs must cooperate with lifecycle security assessments. The 2025/2026 amendment increases fines (up to RMB 10M) and adds emergency shutdown authority for severe violations. Foreign-origin cloud stacks face heightened scrutiny. | **Medium** — increases compliance burden |
> | **Market reality** | China's top 10 cloud providers by market share are **all domestic** (Alibaba 26.8%, Huawei 12.9%, China Telecom 12.3%, etc.). Azure China is not in the top 10. Industry guidance suggests global companies use "local cloud for user-facing services, Azure/AWS China for control plane or corporate workloads." | **High** — market signals reinforce domestic preference |
>
> **Conclusion**: While Azure China (21Vianet) remains **legally permissible**, the combination of SM2/SM3/SM4 compliance uncertainty, Xinchuang/ITAI procurement preferences, government procurement rules, and market dynamics creates a **de-facto barrier** for new CII cloud deployments. Existing deployments are not immediately threatened, but new deployments targeting CII infrastructure should **evaluate domestic cloud alternatives** (Huawei Cloud, Alibaba Cloud, China Telecom eCloud) as the primary platform, with Azure China reserved for corporate/internal workloads where Xinchuang/ITAI pressure is lower.
>
> **Recommended actions**:
> 1. Request formal SM2/SM3/SM4 compliance documentation from 21Vianet/Azure China support.
> 2. Assess whether application-layer SM-algorithm wrappers can bridge the platform gap (adds cost and complexity).
> 3. Evaluate dual-cloud architecture: domestic cloud (e.g. Huawei Cloud) for CII-facing services + Azure China for internal/corporate workloads.
> 4. Track Xinchuang/ITAI approved-vendor lists and CII procurement tender requirements quarterly.
> 5. Engage local legal counsel specializing in China CII and IT procurement.

---

## Scenario 6 — All of the Above (Most Restrictive Superset)

**Deployment**: Product must support on-prem (US/EU/China) and cloud (US/EU/China) simultaneously.

### Cumulative Regulatory Requirements

All standards from Scenarios 1–5 apply. The product must satisfy the **strictest requirement** from each domain:

| Domain | Most Restrictive Requirement | Driven By |
| --------------- | -------------- | -------------- |
| Data residency | Region-locked data storage; no cross-border personal data flow without per-region legal mechanism | China PIPL (strictest), GDPR (EU), US state laws (least restrictive) |
| Incident reporting | 24h early warning + 72h full notification | NIS 2 (EU) — stricter than US state laws (30–60 days) and China 24h to CAC |
| AI governance | EU AI Act human oversight, transparency, bias monitoring, continuous performance monitoring | EU AI Act |
| Audit trails | Immutable, per-region, compliant with GDPR right to erasure (requires pseudonymization strategy) | GDPR Art. 17 |
| Source code exposure | Must be prepared for government review in China while maintaining IP protection in US/EU | China MLPS 2.0 |
| Deployment model | Minimum 3 independent deployment environments (US, EU, China) with no data sharing | GDPR + PIPL + US state laws combined |
| Certification | ISO 27001 + SOC 2 Type II + BSI C5 + MLPS 2.0 Level III | Combined customer expectations |
| Cryptography | Dual crypto stacks: AES/RSA/SHA (US/EU) + SM4/SM2/SM3 (China) | China Cryptography Law + CII Crypto Provisions vs FIPS 140-2 |
| Technology stack | Assess Xinchuang/ITAI compliance of all foreign components for China CII deployments | Xinchuang/ITAI Document 79 |

### Key Architectural Decisions Required

1. **Multi-region isolation**: Minimum three fully independent deployments (US, EU, China) with no shared personal data, no shared identity provider for China, and separate AI model instances.

2. **GDPR Art. 17 audit trail conflict**: GDPR requires the right to erasure, but audit integrity requires complete trails. Resolution: anonymize/pseudonymize records upon erasure request while retaining the audit trail with non-identifiable references.

3. **AI model lifecycle**: Separate model registries per region; no training data crosses borders. Use federated learning or synthetic data approaches where cross-region model improvement is needed.

4. **IP protection vs China review**: Consider modular architecture where China-specific components are separable; minimize exposure of core IP to government review by abstracting proprietary algorithms behind well-defined interfaces.

5. **Crypto-agile architecture**: Design the cryptographic layer behind an abstraction (provider/factory pattern) so that SM2/SM3/SM4 implementations can be swapped in for China deployments while AES/RSA/SHA remain the default for US/EU. Avoid hard-coding algorithm choices. Key management, certificate chains, and TLS configuration must be region-parameterised.

6. **Xinchuang/ITAI supply-chain assessment**: Maintain a registry of all third-party and platform dependencies (OS, runtime, database, middleware, libraries). For each China CII deployment, map dependencies against Xinchuang/ITAI-approved vendor lists and identify components requiring replacement with domestic or open-source alternatives. This is an ongoing obligation as approved lists evolve.

7. **Certification management**: Maintain a unified ISMS (ISO 27001) with regional scope statements covering US, EU, and China-specific requirements.

---

## Product Management Responsibility

For each product/service, Product Management **must** formally specify:

1. **Target markets** — which geographic regions the product will be sold/deployed in.
2. **Deployment model** — on-prem, cloud, or hybrid per region.
3. **Data flows** — which data crosses regional boundaries (if any) and the legal basis.
4. **AI components** — whether the product includes AI/ML, triggering EU AI Act obligations.
5. **Xinchuang/ITAI exposure** — whether the product targets Chinese CII sectors and the resulting supply-chain indigenization requirements.
6. **Cryptographic requirements** — whether SM2/SM3/SM4 are required for the China deployment, and whether dual crypto stacks are needed.
7. **Regulatory profile** — the resulting combination of scenarios from this document.

This specification must be documented before architectural decisions are made and reviewed whenever target markets or deployment models change.
