# OSSASAI - Open Security Standard for Agentic Systems

[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-0.1.0-blue)](CHANGELOG.md)

**OSSASAI** is a vendor-neutral, community-driven security framework for AI agent systems that interact with external tools, filesystems, networks, and users.

## How This Framework Works

OSSASAI is a **compliance and documentation framework** — similar to OWASP ASVS, CIS Benchmarks, or PCI-DSS. It does not require target platforms to implement or recognize it.

### Framework Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    OSSASAI (This Framework)                          │
│                                                                      │
│  Defines:                                                            │
│  • 24 Security Controls across 7 domains                            │
│  • 3 Assurance Levels (L1/L2/L3)                                    │
│  • 4 Trust Boundaries (B1-B4)                                       │
│  • Threat Model (AATT - AI Agent Threat Taxonomy)                   │
│  • Generic verification procedures                                   │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   Implementation Profiles                            │
│                                                                      │
│  Map OSSASAI controls to specific platforms:                        │
│  • OCSAS → OpenClaw                                                 │
│  • (Future) → Claude Code, Cursor, other AI agents                  │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Target Platforms                                  │
│                                                                      │
│  • Do NOT need to know about OSSASAI                                │
│  • Already have security features we document                        │
│  • We use their existing CLI/config for verification                │
└─────────────────────────────────────────────────────────────────────┘
```

### Analogy: Industry Standards

| Standard | What It Does | Does Target Software Know About It? |
|----------|--------------|-------------------------------------|
| CIS Benchmarks | Documents secure configurations | No - CIS maps existing OS settings |
| OWASP ASVS | Verifies application security | No - ASVS checks existing features |
| PCI-DSS | Audits payment security | No - auditors verify existing controls |
| **OSSASAI** | **Verifies AI agent security** | **No - profiles map existing features** |

### Who Uses OSSASAI?

| User | How They Use It |
|------|-----------------|
| **AI agent users** | Deployment checklists, hardening guides |
| **Security auditors** | Structured compliance verification |
| **Enterprises** | Vendor risk assessment, due diligence |
| **Platform developers** | Security architecture guidance |
| **Regulators** | AI agent security evaluation criteria |

---

## Why OSSASAI?

Traditional security frameworks don't adequately address AI agent-specific threats:

- **Prompt injection** - Manipulating agent behavior through crafted inputs
- **Tool abuse** - Misusing legitimate capabilities for unintended purposes
- **Context poisoning** - Corrupting conversation history or memory
- **Identity confusion** - Exploiting multi-user messaging environments
- **Capability escalation** - Chaining tool invocations for unauthorized access

OSSASAI provides structured controls for these threats while building on established security principles.

---

## Core Concepts

### Assurance Levels

| Level | Name | Description |
|-------|------|-------------|
| **L1** | Local-First | Single-user, loopback-only, minimal attack surface |
| **L2** | Network-Aware | Multi-user, LAN/VPN exposure, team deployments |
| **L3** | High-Assurance | Production, public exposure, regulated environments |

### Trust Boundaries

| Boundary | Name | Description |
|----------|------|-------------|
| **B1** | Inbound Identity | Message sources and sender verification |
| **B2** | Control Plane | Administrative interfaces and configuration |
| **B3** | Tool Governance | Capability restrictions and sandboxing |
| **B4** | Local State | Secrets, logs, and persistent data |

### Control Domains

| Domain | Controls | Focus |
|--------|----------|-------|
| **GEN** | 5 | General security principles |
| **CP** | 4 | Control plane exposure, authentication |
| **ID** | 3 | Peer verification, session isolation |
| **TB** | 4 | Tool least privilege, sandboxing |
| **LS** | 4 | Secrets, log redaction, retention |
| **SC** | 2 | Plugin trust, supply chain |
| **FV** | 3 | Formal verification (optional) |
| **NS** | 4 | TLS, certificates, API security |

---

## Framework Structure

```
ossasai/
├── spec/                     # Core specification
│   ├── overview.mdx          # Framework overview
│   ├── assurance-levels.mdx  # L1/L2/L3 definitions
│   ├── trust-boundaries.mdx  # B1-B4 definitions
│   └── compliance-workflow.mdx
├── threat-model/             # Threat analysis
│   ├── adversary-classes.mdx # A1-A5 taxonomy
│   ├── ai-agent-threats.mdx  # AATT (AI Agent Threat Taxonomy)
│   ├── attack-vectors.mdx
│   └── risk-scoring.mdx
├── controls/                 # Security controls
│   ├── general.mdx           # GEN-01 to GEN-05
│   ├── control-plane.mdx     # CP-01 to CP-04
│   ├── identity-session.mdx  # ID-01 to ID-03
│   ├── tool-blast-radius.mdx # TB-01 to TB-04
│   ├── local-state.mdx       # LS-01 to LS-04
│   ├── supply-chain.mdx      # SC-01 to SC-02
│   ├── formal-verification.mdx # FV-01 to FV-03
│   └── network-security.mdx  # NS-01 to NS-04
├── implementation/           # Deployment guides
│   ├── quickstart.mdx        # Rapid secure deployment
│   ├── l1-deployment.mdx     # Local-first setup
│   ├── l2-deployment.mdx     # Network-aware setup
│   └── l3-deployment.mdx     # High-assurance setup
├── testing/                  # Security testing
├── compliance/               # Evidence collection
├── incident-response/        # Playbooks
├── tools/                    # Reference tooling
└── appendices/               # Standards mapping
```

---

## Implementation Profiles

OSSASAI is implemented through **platform-specific profiles** that map generic controls to actual platform features.

| Profile | Platform | Repository | Status |
|---------|----------|------------|--------|
| **OCSAS** | OpenClaw | [github.com/gensecaihq/ocsas](https://github.com/gensecaihq/ocsas) | Active |

### How Profiles Work

```
OSSASAI Control: "OSSASAI-ID-01: Peer Verification"
       ↓
Profile Mapping (OCSAS): "OpenClaw implements this via dmPolicy: 'pairing'"
       ↓
Verification: "Run 'openclaw security audit' to check"
       ↓
Auditor: "Control ID-01 ✓ - Compliant"
```

### Creating New Profiles

To create a profile for a new platform:

1. **Inventory the platform's security features** - What authentication, sandboxing, logging does it have?
2. **Map to OSSASAI controls** - Which features satisfy which controls?
3. **Define verification steps** - How to check each control using the platform's own tools?
4. **Document conformance recipes** - L1/L2/L3 configuration templates

---

## Getting Started

### For Users

1. **Choose your platform** - Find an implementation profile (e.g., OCSAS for OpenClaw)
2. **Choose your assurance level** - L1, L2, or L3 based on deployment context
3. **Follow the conformance recipe** - Apply the profile's configuration guidance
4. **Verify compliance** - Run the platform's audit tools as documented in the profile

### For Auditors

1. **Review the threat model** - Understand AI-specific threats ([threat-model/](threat-model/))
2. **Identify applicable controls** - Based on assurance level requirements
3. **Use profile verification steps** - Platform-specific audit commands
4. **Collect evidence** - Generate compliance artifacts

### For Platform Developers

1. **Review the controls catalog** - Understand security requirements ([controls/](controls/))
2. **Self-assess your platform** - Which controls are already implemented?
3. **Create an implementation profile** - Document the mappings
4. **Contribute** - Submit your profile as a new repository

---

## Standards Alignment

OSSASAI builds on established security frameworks:

| Standard | Alignment |
|----------|-----------|
| OWASP ASVS v4.0 | Authentication, session management, access control |
| NIST SP 800-53 Rev 5 | AC, AU, CM, IA, SC control families |
| CIS Controls v8 | Controls 3, 4, 5, 6, 12, 16 |
| MITRE ATT&CK | Tactic and technique mapping |
| RFC 2119 | Normative language (MUST/SHOULD/MAY) |

---

## Contributing

Contributions welcome:

- **Framework improvements** - Submit issues and PRs to this repository
- **Implementation profiles** - Create profiles for new AI agent platforms
- **Security research** - Contribute threat intelligence and attack patterns
- **Standards mapping** - Help align with additional security frameworks

---

## Documentation

| Document | Description |
|----------|-------------|
| [spec/overview.mdx](spec/overview.mdx) | Framework specification |
| [controls/overview.mdx](controls/overview.mdx) | Control catalog |
| [threat-model/overview.mdx](threat-model/overview.mdx) | Threat model |
| [implementation/quickstart.mdx](implementation/quickstart.mdx) | Quick start guide |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [SECURITY.md](SECURITY.md) | Security policy |

---

## License

[Apache License 2.0](LICENSE)

---

**OSSASAI v0.1.0** | Open Security Standard for Agentic Systems
