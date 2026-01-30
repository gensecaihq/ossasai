# OSSASAI - Open Security Standard for Agentic Systems

[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-0.1.0-blue)](CHANGELOG.md)

**OSSASAI** is a vendor-neutral, community-driven security framework for AI agent systems that interact with external tools, filesystems, networks, and users.

## Why OSSASAI?

Traditional security frameworks don't adequately address AI agent-specific threats:

- **Prompt injection** - Manipulating agent behavior through crafted inputs
- **Tool abuse** - Misusing legitimate capabilities for unintended purposes
- **Context poisoning** - Corrupting conversation history or memory
- **Identity confusion** - Exploiting multi-user messaging environments
- **Capability escalation** - Chaining tool invocations for unauthorized access

OSSASAI provides structured controls for these threats while building on established security principles.

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
| **CP** | 4 | Control plane exposure, authentication |
| **ID** | 3 | Peer verification, session isolation |
| **TB** | 4 | Tool least privilege, sandboxing |
| **LS** | 4 | Secrets, log redaction, retention |
| **SC** | 2 | Plugin trust, supply chain |
| **FV** | 3 | Formal verification (optional) |
| **NS** | 4 | TLS, certificates, API security |

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
│   ├── control-plane.mdx     # CP-01 to CP-04
│   ├── identity-session.mdx  # ID-01 to ID-03
│   ├── tool-blast-radius.mdx # TB-01 to TB-04
│   ├── local-state.mdx       # LS-01 to LS-04
│   ├── supply-chain.mdx      # SC-01 to SC-02
│   ├── formal-verification.mdx # FV-01 to FV-03
│   └── network-security.mdx  # NS-01 to NS-04
├── implementation/           # Deployment guides
├── testing/                  # Security testing
├── compliance/               # Evidence collection
├── incident-response/        # Playbooks
├── tools/                    # Reference tooling
└── appendices/               # Standards mapping
```

## Implementation Profiles

OSSASAI is implemented through platform-specific profiles:

| Profile | Platform | Repository |
|---------|----------|------------|
| **OCSAS** | OpenClaw | [github.com/gensecaihq/ocsas](https://github.com/gensecaihq/ocsas) |

## Standards Alignment

| Standard | Alignment |
|----------|-----------|
| OWASP ASVS v4.0 | Authentication, session management, access control |
| NIST SP 800-53 Rev 5 | AC, AU, CM, IA, SC control families |
| CIS Controls v8 | Controls 3, 4, 5, 6, 12, 16 |
| MITRE ATT&CK | Tactic and technique mapping |

## Getting Started

1. **Review the threat model** - Understand adversary classes and AI-specific threats
2. **Choose your assurance level** - L1, L2, or L3 based on deployment context
3. **Review applicable controls** - Identify requirements for your level
4. **Use an implementation profile** - Platform-specific guidance (e.g., OCSAS for OpenClaw)
5. **Verify compliance** - Run automated audits and collect evidence

## Contributing

Contributions welcome:

- **Framework improvements** - Submit issues and PRs
- **Implementation profiles** - Create profiles for new platforms
- **Security research** - Contribute threat intelligence

## Documentation

| Document | Description |
|----------|-------------|
| [spec/overview.mdx](spec/overview.mdx) | Framework specification |
| [controls/overview.mdx](controls/overview.mdx) | Control catalog |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [SECURITY.md](SECURITY.md) | Security policy |

## License

[Apache License 2.0](LICENSE)

---

**OSSASAI v0.1.0** | Open Security Standard for Agentic Systems
