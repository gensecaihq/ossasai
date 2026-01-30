---
layout: default
title: Home
nav_order: 1
description: "OSSASAI - Open Security Standard for Agentic Systems"
permalink: /
---

# OSSASAI - Open Security Standard for Agentic Systems

A vendor-neutral, community-driven security framework designed specifically for AI agent systems that interact with external tools, filesystems, networks, and users.

---

## Overview

**OSSASAI** provides a structured approach to securing AI agent systems against unique threats including prompt injection attacks, tool abuse, context poisoning, identity confusion, and capability escalation.

> **Design Philosophy:** "Access control before intelligence." Most AI agent security failures are not sophisticated exploits—they're cases where "someone messaged the bot and the bot did what they asked." OSSASAI's stance: Identity first, scope next, model last.

---

## Framework Structure

| Section | Description |
|---------|-------------|
| [Specification](spec/overview.md) | Core requirements using RFC 2119 normative language (MUST/SHOULD/MAY) |
| [Threat Model](threat-model/overview.md) | Adversary taxonomy, attack vectors, and AI-specific threats |
| [Controls](controls/overview.md) | 30 security controls across 8 domains |
| [Implementation](implementation/quickstart.md) | Deployment guides for each assurance level |
| [Testing](testing/overview.md) | Verification procedures and automated auditing |
| [Compliance](compliance/overview.md) | Evidence collection and reporting |
| [Incident Response](incident-response/overview.md) | Playbooks and recovery procedures |
| [Profiles](profiles/overview.md) | Platform-specific implementation mappings |

---

## Assurance Levels

OSSASAI defines three assurance levels based on deployment context and risk tolerance:

| Level | Name | Description |
|-------|------|-------------|
| **L1** | Local-First | Single-user, loopback-only deployments with minimal attack surface |
| **L2** | Network-Aware | Multi-user deployments with LAN/VPN exposure |
| **L3** | High-Assurance | Production deployments with public exposure or regulatory requirements |

---

## Trust Boundaries

The framework defines four trust boundaries that must be secured:

| Boundary | Name | Description |
|----------|------|-------------|
| **B1** | Inbound Identity | Message sources and sender verification |
| **B2** | Control Plane | Administrative interfaces and configuration |
| **B3** | Tool Governance | Capability restrictions and sandboxing |
| **B4** | Local State | Secrets, logs, and persistent data |

---

## Control Domains

| Domain | ID | Controls | Description |
|--------|-------|----------|-------------|
| General | GEN | 5 | Security by default, fail secure, least privilege, defense in depth, audit logging |
| Control Plane | CP | 4 | Gateway exposure, authentication, proxy trust |
| Identity & Session | ID | 3 | Peer verification, session isolation, group policies |
| Tool Blast Radius | TB | 4 | Least privilege, approval gates, sandboxing |
| Local State | LS | 4 | Secrets protection, log redaction, retention |
| Supply Chain | SC | 3 | Plugin trust, reproducible builds, artifact signing |
| Formal Verification | FV | 3 | Security invariants, testing, CI integration |
| Network Security | NS | 4 | TLS, certificates, API security |

---

## Getting Started

1. **Understand the threat model** - Review [adversary classes](threat-model/adversary-classes.md) and [AI agent threats](threat-model/ai-agent-threats.md)
2. **Choose your assurance level** - Based on deployment context, select [L1, L2, or L3](spec/assurance-levels.md)
3. **Review applicable controls** - Identify controls required for your assurance level
4. **Implement controls** - Follow [implementation guides](implementation/quickstart.md) or use a platform-specific profile
5. **Verify compliance** - Use [automated auditing](testing/automated-audit.md) and evidence collection

---

## Implementation Profiles

OSSASAI is designed to be implemented by specific AI agent platforms through **implementation profiles**. Each profile maps OSSASAI controls to platform-specific features, configurations, and tooling.

- [Profile Registry](profiles/registry.md) - Central catalog of all OSSASAI profiles
- [OCSAS - OpenClaw Security Assurance Standard](profiles/openclaw.md) - Reference implementation profile

---

## Standards Alignment

OSSASAI maps to established security frameworks:

| Standard | Alignment |
|----------|-----------|
| OWASP ASVS v4.0 | Authentication, session management, access control |
| NIST SP 800-53 | AC, AU, CM, IA, SC control families |
| NIST AI RMF | AI-specific risk management |
| CIS Controls v8 | Controls 3, 4, 5, 6, 12, 16 |
| MITRE ATT&CK | Tactic and technique mapping |

---

## Contributing

OSSASAI is an open standard. Contributions are welcome:

- **Framework improvements** - Submit issues and PRs to the [OSSASAI repository](https://github.com/gensecaihq/ossasai)
- **Implementation profiles** - Create profiles for additional AI agent platforms
- **Security research** - Report vulnerabilities and contribute threat intelligence

---

## Version

**OSSASAI v0.2.0** - January 2026

This release includes 30 security controls, a complete profile registry system, and production-ready tooling.
