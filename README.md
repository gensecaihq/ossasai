# OSSASAI - Open Security Standard for Agentic Systems

[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-0.1.0-blue)](appendices/changelog.mdx)

**OSSASAI** (Open Security Standard for Agentic Systems) is a vendor-neutral, community-driven security framework designed specifically for AI agent systems that interact with external tools, filesystems, networks, and users.

## Why OSSASAI?

Traditional security frameworks (OWASP, NIST, CIS) address general application and infrastructure security but don't adequately cover the unique threat landscape of AI agents:

- **Prompt injection attacks** that manipulate agent behavior
- **Tool abuse** where legitimate capabilities are misused
- **Context poisoning** through malicious conversation history
- **Identity confusion** in multi-user messaging environments
- **Capability escalation** through chained tool invocations

OSSASAI provides a structured approach to these AI-specific threats while building on established security principles.

## Design Philosophy

> "Access control before intelligence."

Most AI agent security failures are not sophisticated exploits—they're cases where "someone messaged the bot and the bot did what they asked." OSSASAI's stance: **Identity first, scope next, model last.**

## Framework Structure

```
ossasai/
├── introduction.mdx          # Framework overview
├── spec/                     # Core specification (RFC 2119 normative)
│   ├── overview.mdx          # Specification overview
│   ├── assurance-levels.mdx  # L1/L2/L3 definitions
│   ├── trust-boundaries.mdx  # B1-B4 boundary definitions
│   └── compliance-workflow.mdx
├── threat-model/             # Threat analysis
│   ├── overview.mdx          # Threat model introduction
│   ├── adversary-classes.mdx # A1-A5 adversary taxonomy
│   ├── attack-vectors.mdx    # Attack surface analysis
│   ├── ai-agent-threats.mdx  # AI Agent Threat Taxonomy (AATT)
│   └── risk-scoring.mdx      # Blast radius framework
├── controls/                 # Security controls (24 total)
│   ├── overview.mdx          # Control catalog
│   ├── control-plane.mdx     # CP-01 to CP-04
│   ├── identity-session.mdx  # ID-01 to ID-03
│   ├── tool-blast-radius.mdx # TB-01 to TB-04
│   ├── local-state.mdx       # LS-01 to LS-04
│   ├── supply-chain.mdx      # SC-01 to SC-02
│   ├── formal-verification.mdx # FV-01 to FV-03
│   └── network-security.mdx  # NS-01 to NS-04
├── implementation/           # Deployment guides
├── testing/                  # Security testing methodology
├── compliance/               # Compliance program
├── incident-response/        # IR procedures
├── tools/                    # Audit scripts and automation
└── appendices/               # Standards mapping, glossary
```

## Assurance Levels

| Level | Name | Use Case |
|-------|------|----------|
| **L1** | Local-First | Single-user, loopback-only deployments |
| **L2** | Network-Aware | Multi-user, LAN/VPN exposure |
| **L3** | High-Assurance | Production, public-facing, regulated environments |

## Trust Boundaries

| Boundary | Name | Description |
|----------|------|-------------|
| **B1** | Inbound Identity | Message sources and sender verification |
| **B2** | Control Plane | Administrative interfaces and configuration |
| **B3** | Tool Governance | Capability restrictions and sandboxing |
| **B4** | Local State | Secrets, logs, and persistent data |

## Control Domains

| Domain | ID | Controls | Focus |
|--------|-------|----------|-------|
| Control Plane | CP | 4 | Gateway exposure, authentication, proxy trust |
| Identity & Session | ID | 3 | Peer verification, session isolation |
| Tool Blast Radius | TB | 4 | Least privilege, approval gates, sandboxing |
| Local State | LS | 4 | Secrets protection, log redaction, retention |
| Supply Chain | SC | 2 | Plugin trust, reproducible builds |
| Formal Verification | FV | 3 | Security invariants, negative testing |
| Network Security | NS | 4 | TLS, certificates, API security |

## Implementation Profiles

OSSASAI is implemented through platform-specific **profiles** that map controls to concrete features:

| Profile | Platform | Repository |
|---------|----------|------------|
| **OCSAS** | OpenClaw | [github.com/gensecaihq/ocsas](https://github.com/gensecaihq/ocsas) |

> Want to create a profile for another AI agent platform? See [Creating Implementation Profiles](implementation/quickstart.mdx).

## Standards Mapping

OSSASAI aligns with established security frameworks:

| Standard | Alignment |
|----------|-----------|
| OWASP ASVS v4.0 | Authentication, session management, access control |
| NIST SP 800-53 Rev 5 | AC, AU, CM, IA, SC control families |
| NIST AI RMF | AI-specific risk management practices |
| CIS Controls v8 | Controls 3, 4, 5, 6, 12, 16 |
| MITRE ATT&CK | Tactic and technique mapping |
| Common Criteria | EAL alignment for assurance levels |

## Quick Start

### 1. Understand the Threat Model

```bash
# Review adversary classes and AI-specific threats
cat threat-model/adversary-classes.mdx
cat threat-model/ai-agent-threats.mdx
```

### 2. Choose Your Assurance Level

Based on your deployment context:
- **L1**: Local development, single user
- **L2**: Team deployment, internal network
- **L3**: Production, external users

### 3. Use an Implementation Profile

For OpenClaw deployments, use [OCSAS](https://github.com/gensecaihq/ocsas):

```bash
# Clone the OCSAS profile
git clone https://github.com/gensecaihq/ocsas

# Run security audit (OpenClaw)
openclaw security audit --deep
```

## Tooling

OSSASAI provides reference tooling:

- **`ossasai-audit.sh`** - Bash script for automated compliance checking
- **`ossasai-report.py`** - Python script for compliance report generation
- **`ossasai-github-action.yml`** - CI/CD integration workflow

## Contributing

OSSASAI is an open standard. Contributions welcome:

- **Framework improvements** - Submit issues and PRs
- **Implementation profiles** - Create profiles for new platforms
- **Security research** - Contribute threat intelligence

## Related Projects

- [OCSAS](https://github.com/gensecaihq/ocsas) - OpenClaw implementation profile
- [OpenClaw](https://openclaw.ai) - AI agent gateway for messaging platforms

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.

---

**OSSASAI v0.1.0** | January 2025 | Open Security Standard for Agentic Systems
