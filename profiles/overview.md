---
layout: default
title: Profiles
nav_order: 10
has_children: true
description: 'Platform-specific mappings of OSSASAI controls to concrete configurations'
permalink: /profiles/
---

## Overview

OSSASAI Profiles provide ecosystem-specific implementations of the security control catalog. While OSSASAI defines vendor-neutral requirements, profiles map these requirements to concrete platform configurations, enabling consistent security assurance across different AI agent runtimes.

> **Note:** Profiles are essential for practical OSSASAI implementation. They translate abstract security requirements into platform-specific configurations that operators can directly apply.

## Profile Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        OSSASAI Profile Architecture                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐│
│  │                    OSSASAI Control Catalog                             ││
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐          ││
│  │  │  GEN-*  │ │  CP-*   │ │  TB-*   │ │  LS-*   │ │  NS-*   │ ...      ││
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘          ││
│  └────────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│                                    ▼                                        │
│  ┌────────────────────────────────────────────────────────────────────────┐│
│  │                     Implementation Profiles                             ││
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      ││
│  │  │   OpenClaw  │ │  LangChain  │ │   AutoGPT   │ │   Custom    │      ││
│  │  │    OCSAS    │ │   Profile   │ │   Profile   │ │   Profile   │      ││
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      ││
│  └────────────────────────────────────────────────────────────────────────┘│
│                                    │                                        │
│                                    ▼                                        │
│  ┌────────────────────────────────────────────────────────────────────────┐│
│  │                Platform-Specific Configurations                         ││
│  │  config.yaml, policies/, .env, hooks/, audit scripts                   ││
│  └────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Profile Requirements

A conformant OSSASAI Profile MUST include:

| Component | Description | Required |
|-----------|-------------|:--------:|
| **Profile ID** | Unique identifier: `OSSASAI-PROFILE-[PLATFORM]-[NAME]-[VERSION]` | Yes |
| **Control Mapping** | Table mapping each OSSASAI control to platform config | Yes |
| **Evidence Procedures** | How to generate required evidence artifacts | Yes |
| **Verification Tooling** | Platform-specific audit commands and scripts | Yes |
| **Conformance Recipes** | Step-by-step deployment guides for L1/L2/L3 | Yes |
| **Platform Extensions** | Additional platform-specific controls (if any) | No |

## Profile Identification Schema

```
OSSASAI-PROFILE-[PLATFORM]-[NAME]-[VERSION]
              │           │       │
              │           │       └─── Semantic version (1.0.0)
              │           │
              │           └─── Profile name (OCSAS, SECURITY, etc.)
              │
              └─── Platform identifier (OPENCLAW, LANGCHAIN, etc.)

Example: OSSASAI-PROFILE-OPENCLAW-OCSAS-1.0.0
```

## Profile Registry

The OSSASAI Profile Registry provides a central endpoint for profile management, version tracking, and change notifications. Profiles registered with the registry receive automatic notifications when framework changes may affect their implementations.

### [Profile Registry](/profiles/registry)

Central registry of all OSSASAI profiles with compatibility tracking, webhook notifications, and API access.


### Registry Benefits

- **Change Notifications**: Webhooks notify maintainers of framework changes
- **Compatibility Tracking**: Automatic compatibility checks against OSSASAI versions
- **Version Management**: Track profile versions and migration requirements
- **Discovery**: Make your profile discoverable to the community

## Available Profiles


  ### [OCSAS - OpenClaw Security Assurance Standard](/profiles/openclaw)

Official OSSASAI implementation profile for OpenClaw agent runtime. Complete control mapping with CLI-based verification.

    **Version:** 1.0.0
    **Assurance Levels:** L1, L2, L3
    **Status:** Official

  ### [Community Profiles](/profiles/registry)

Community-contributed profiles for other platforms. Register your profile to receive change notifications.

    **Platforms:** Various
    **Status:** Community-maintained


## Creating a Profile

### Profile Template

```yaml
# OSSASAI Profile Template
# Profile ID: OSSASAI-PROFILE-[PLATFORM]-[NAME]-[VERSION]

profile:
  id: "OSSASAI-PROFILE-MYPLATFORM-SECURITY-1.0.0"
  name: "MyPlatform Security Profile"
  platform: "myplatform"
  version: "1.0.0"
  ossasai_version: "1.0.0"

  maintainers:
    - name: "Your Name"
      email: "email@example.com"

# Control mappings
mappings:
  # General controls
  OSSASAI-GEN-01:
    platform_config: "security.enabled"
    default_value: true
    verification_command: "myplatform security check --control GEN-01"
    documentation: "https://docs.myplatform.com/security"
    notes: "Enabled by default in v2.0+"

  OSSASAI-GEN-02:
    platform_config: "error_handling.fail_secure"
    default_value: true
    verification_command: "myplatform security check --control GEN-02"

  # Control Plane controls
  OSSASAI-CP-01:
    platform_config: "server.bind_address"
    default_value: "127.0.0.1:8080"
    verification_command: "myplatform security check --control CP-01"

  # ... continue for all 30 controls

# Evidence procedures
evidence:
  GEN-01:
    artifacts:
      - type: "config_snapshot"
        path: "~/.myplatform/config.yaml"
        description: "Configuration showing security enabled by default"
    procedure: |
      1. Export configuration: `myplatform config export > config.yaml`
      2. Verify security.enabled is true
      3. Run fresh install test: `myplatform --factory-reset && myplatform security audit`

  # ... continue for all controls

# Verification tooling
verification:
  audit_command: "myplatform security audit --ossasai"
  report_command: "myplatform security report"
  supported_formats:
    - json
    - yaml
    - junit

# Conformance recipes
recipes:
  L1:
    description: "Local-first deployment"
    steps:
      - "Install myplatform"
      - "Run: myplatform init --security-baseline"
      - "Verify: myplatform security audit --level L1"

  L2:
    description: "Network-aware deployment"
    steps:
      - "Complete L1 setup"
      - "Configure TLS: myplatform tls enable"
      - "Configure auth: myplatform auth setup"
      - "Verify: myplatform security audit --level L2"

  L3:
    description: "High-assurance deployment"
    steps:
      - "Complete L2 setup"
      - "Enable signing: myplatform signing enable"
      - "Configure monitoring: myplatform monitor setup"
      - "Verify: myplatform security audit --level L3"
```

### Submission Process

1. **Fork** the OSSASAI repository
2. **Create** your profile in `profiles/[platform].md`
3. **Validate** using the profile schema
4. **Test** all control mappings and verification commands
5. **Submit** a pull request with:
   - Profile documentation
   - Control mapping table
   - Verification tooling
   - Test evidence

### Validation Checklist

Before submitting a profile:

- [ ] All 30 controls have platform mappings
- [ ] Verification commands work for each control
- [ ] Evidence procedures are documented
- [ ] L1/L2/L3 recipes are complete and tested
- [ ] Profile follows naming convention
- [ ] Documentation is clear and complete

## Profile Maintenance

### Versioning

Profiles follow semantic versioning:

- **MAJOR**: Breaking changes to control mappings
- **MINOR**: New platform features, additional controls
- **PATCH**: Documentation fixes, clarifications

### Compatibility

| OSSASAI Version | Compatible Profile Versions |
|-----------------|----------------------------|
| 0.2.x (current) | Profiles 1.0.x |
| 1.0.x (future) | Profiles 2.0.x (new schema) |

## Staying Updated with Framework Changes

### Webhook Notifications

Register webhooks to receive automatic notifications when OSSASAI framework changes may affect your profile:

```yaml
# Profile webhook configuration
webhooks:
  url: "https://your-domain.com/webhooks/ossasai"
  events:
    - control_added        # New control added to catalog
    - control_changed      # Existing control modified
    - requirement_elevated # SHOULD→MUST change
    - breaking_change      # Major version change
    - version_released     # New OSSASAI version
  secret: "${WEBHOOK_SECRET}"  # For signature verification
```

### Change Notification Events

| Event | When Triggered | Action Required |
|-------|----------------|-----------------|
| `control_added` | New control in catalog | Map new control to platform |
| `control_changed` | Control definition updated | Review and update mapping |
| `requirement_elevated` | SHOULD→MUST | Ensure control is implemented |
| `breaking_change` | Major version release | Follow migration guide |
| `version_released` | Any new version | Review changelog |

### Checking Compatibility

```bash
# Check your profile against the current framework
curl https://ossasai.dev/api/v1/profiles/YOUR-PROFILE-ID/compatibility

# Or use the CLI
ossasai-audit.sh --check-profile-compatibility ./your-profile.yaml
```

### Framework Change Feed

Subscribe to framework changes via RSS/Atom or poll the API:

```bash
# Get changes since a specific version
curl https://ossasai.dev/api/v1/framework/changes?since=0.1.0

# Get current control catalog
curl https://ossasai.dev/api/v1/framework/controls
```

## Profile Schema

Profiles must conform to the OSSASAI Profile Schema for validation and registry compatibility:

```bash
# Validate your profile
ossasai-audit.sh --validate-profile your-profile.yaml

# Or validate against the JSON schema directly
jsonschema -i your-profile.json \
  https://github.com/gensecaihq/ossasai/tree/main/appendices/schemas/profile.schema.json
```

Schema documentation: [Profile Schema](/appendices/schemas/profile.schema.json)

## References

- [Profile Registry](/profiles/registry)
- [Profile Schema](/appendices/schemas/profile.schema.json)
- [OSSASAI Specification](/spec/overview)
- [Control Catalog](/controls/overview)
- [Implementation Guides](/implementation/quickstart)
