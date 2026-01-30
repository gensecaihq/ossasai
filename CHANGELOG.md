# Changelog

All notable changes to OSSASAI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-30

### Added

- Initial release of OSSASAI (Open Security Standard for Agentic Systems)
- Core specification with RFC 2119 normative language
- Three assurance levels: L1 (Local-First), L2 (Network-Aware), L3 (High-Assurance)
- Four trust boundaries: B1 (Inbound Identity), B2 (Control Plane), B3 (Tool Governance), B4 (Local State)
- 24 security controls across 7 domains:
  - **Control Plane (CP):** 4 controls
  - **Identity & Session (ID):** 3 controls
  - **Tool Blast Radius (TB):** 4 controls
  - **Local State (LS):** 4 controls
  - **Supply Chain (SC):** 2 controls
  - **Formal Verification (FV):** 3 controls
  - **Network Security (NS):** 4 controls
- Threat model with adversary taxonomy (A1-A5)
- AI Agent Threat Taxonomy (AATT)
- Risk scoring framework
- Implementation guides for each assurance level
- Security testing methodology
- Compliance and evidence collection procedures
- Incident response playbooks
- Standards mapping (OWASP ASVS, NIST SP 800-53, CIS Controls)
- Reference tooling (audit scripts, report generator, CI workflow)
- Mintlify documentation configuration

## Implementation Profiles

- [OCSAS](https://github.com/gensecaihq/ocsas) - OpenClaw implementation profile
