---
layout: default
title: OCSAS (OpenClaw)
parent: Profiles
nav_order: 2
description: 'OSSASAI implementation profile for OpenClaw agent runtime'
---

## Profile Information

| Attribute | Value |
|-----------|-------|
| **Profile ID** | OSSASAI-PROFILE-OPENCLAW-OCSAS-1.0.0 |
| **Platform** | OpenClaw |
| **Version** | 1.0.0 |
| **OSSASAI Version** | 1.0.0 |
| **Assurance Levels** | L1, L2, L3 |
| **Status** | Official |

## Overview

OCSAS (OpenClaw Security Assurance Standard) is the official OSSASAI implementation profile for the OpenClaw agent runtime. It provides complete control mappings, verification tooling, and deployment recipes for all three assurance levels.

> **Note:** OCSAS is maintained by the OSSASAI project team and serves as the reference implementation for other profiles.

## Control Mappings

### General Controls (GEN)

| Control | Config Path | Default | Verification |
|---------|-------------|---------|--------------|
| OSSASAI-GEN-01 | `security.enabled` | `true` | `openclaw security audit --check GEN-01` |
| OSSASAI-GEN-02 | `error_handling.fail_secure` | `true` | `openclaw security audit --check GEN-02` |
| OSSASAI-GEN-03 | `permissions.default_policy` | `"deny"` | `openclaw security audit --check GEN-03` |
| OSSASAI-GEN-04 | `security.defense_in_depth` | `true` (L2+) | `openclaw security audit --check GEN-04` |
| OSSASAI-GEN-05 | `audit.enabled` | `true` (L2+) | `openclaw security audit --check GEN-05` |

<details>
<summary><strong>GEN Control Configuration Details</strong></summary>

```yaml
# ~/.openclaw/config.yaml - General Controls

# GEN-01: Security by Default
security:
  enabled: true  # MUST be true

# GEN-02: Fail Secure
error_handling:
  fail_secure: true
  on_auth_error: "deny"
  on_policy_error: "deny"
  expose_details: false

# GEN-03: Least Privilege
permissions:
  default_policy: "deny"
  filesystem:
    scope: "workdir"  # Not "system"
  network:
    default: "deny"

# GEN-04: Defense in Depth (L2+)
security:
  defense_in_depth: true
  layers:
    - authentication
    - authorization
    - sandbox
    - audit

# GEN-05: Audit Logging (L2+)
audit:
  enabled: true
  events:
    - "auth.*"
    - "tool.*"
    - "config.*"
  retention: "365d"
```

</details>


### Control Plane Controls (CP)

| Control | Config Path | Default | Verification |
|---------|-------------|---------|--------------|
| OSSASAI-CP-01 | `gateway.bind` | `"127.0.0.1:18789"` | `openclaw security audit --check CP-01` |
| OSSASAI-CP-02 | `auth.required` | `true` | `openclaw security audit --check CP-02` |
| OSSASAI-CP-03 | `gateway.trustedProxies` | `["127.0.0.1"]` | `openclaw security audit --check CP-03` |
| OSSASAI-CP-04 | `identities.*` | See config | `openclaw security audit --check CP-04` |

<details>
<summary><strong>CP Control Configuration Details</strong></summary>

```yaml
# Control Plane Controls

# CP-01: Default-deny Exposure
gateway:
  bind: "127.0.0.1:18789"  # Loopback only
  # For network access, use VPN/tailnet instead of:
  # bind: "0.0.0.0:18789"  # NEVER in production

# CP-02: Strong Admin Authentication
auth:
  required: true
  type: "token"  # or "oidc", "mtls"
  token_rotation_days: 30
  require_on_handshake: true

# CP-03: Proxy Trust Boundary (L2+)
gateway:
  trustedProxies:
    - "127.0.0.1"
    - "10.0.0.0/8"  # Internal network only

# CP-04: Identity Separation (L2+)
identities:
  operator:
    type: "human"
    scopes: ["admin.*", "config.*"]
  agent:
    type: "service"
    scopes: ["tools.execute", "files.read:${workdir}"]
```

</details>


### Identity & Session Controls (ID)

| Control | Config Path | Default | Verification |
|---------|-------------|---------|--------------|
| OSSASAI-ID-01 | `peers.verification` | `true` (L2+) | `openclaw security audit --check ID-01` |
| OSSASAI-ID-02 | `sessions.isolation` | `true` | `openclaw security audit --check ID-02` |
| OSSASAI-ID-03 | `channels.policy` | See config | `openclaw security audit --check ID-03` |

<details>
<summary><strong>ID Control Configuration Details</strong></summary>

```yaml
# Identity & Session Controls

# ID-01: Peer Verification (L2+)
peers:
  verification: true
  auto_accept: false
  require_approval: true

# ID-02: Session Isolation
sessions:
  isolation: true
  share_context: false
  encryption: true

# ID-03: Group Policy (L2+ SHOULD, L3 MUST)
channels:
  policy:
    groups:
      respond_all_mentions: false
      require_direct_address: true
    restrictions:
      sensitive_tools: ["admin", "config"]
```

</details>


### Tool Blast Radius Controls (TB)

| Control | Config Path | Default | Verification |
|---------|-------------|---------|--------------|
| OSSASAI-TB-01 | `tools.filesystem.scope` | `"workdir"` | `openclaw security audit --check TB-01` |
| OSSASAI-TB-02 | `tools.approval.*` | See config | `openclaw security audit --check TB-02` |
| OSSASAI-TB-03 | `sandbox.enabled` | `true` (L2+) | `openclaw security audit --check TB-03` |
| OSSASAI-TB-04 | `network.egress.*` | See config | `openclaw security audit --check TB-04` |

<details>
<summary><strong>TB Control Configuration Details</strong></summary>

```yaml
# Tool Blast Radius Controls

# TB-01: Least Privilege Tools
tools:
  filesystem:
    scope: "workdir"
    follow_symlinks: false
  commands:
    mode: "allowlist"
    allowlist:
      - "git"
      - "npm"
      - "python"

# TB-02: Approval Gates (L2+)
tools:
  approval:
    required_for:
      - "file_delete"
      - "network_external"
      - "command_dangerous"
    timeout: "5m"
    default_on_timeout: "deny"

# TB-03: Sandboxing (L2+)
sandbox:
  enabled: true
  type: "container"  # or "seccomp", "apparmor"
  escape_prevention: true

# TB-04: Egress Controls (L2+)
network:
  egress:
    mode: "allowlist"
    allowed_domains:
      - "api.github.com"
      - "registry.npmjs.org"
    dlp:
      enabled: true
      patterns:
        - "AWS[A-Z0-9]{20}"
        - "ghp_[a-zA-Z0-9]{36}"
```

</details>


### Local State Controls (LS)

| Control | Config Path | Default | Verification |
|---------|-------------|---------|--------------|
| OSSASAI-LS-01 | `secrets.*` | See config | `openclaw security audit --check LS-01` |
| OSSASAI-LS-02 | `logging.redaction` | `true` | `openclaw security audit --check LS-02` |
| OSSASAI-LS-03 | `memory.policy` | See config | `openclaw security audit --check LS-03` |
| OSSASAI-LS-04 | `data.retention` | See config | `openclaw security audit --check LS-04` |

<details>
<summary><strong>LS Control Configuration Details</strong></summary>

```yaml
# Local State Controls

# LS-01: Secrets Protection
secrets:
  encryption:
    enabled: true
    algorithm: "AES-256-GCM"
  storage:
    permissions: "0600"
    location: "${HOME}/.openclaw/secrets"

# LS-02: Log Redaction
logging:
  redaction:
    enabled: true
    patterns:
      - "password"
      - "secret"
      - "token"
      - "api_key"
      - "AWS[A-Z0-9]{20}"

# LS-03: Memory Safety (L1 SHOULD, L2+ MUST)
memory:
  policy:
    trust_context: false
    sanitize_input: true
    injection_prevention: true

# LS-04: Retention (L2+)
data:
  retention:
    sessions: "90d"
    logs: "365d"
    audit: "7y"
  deletion:
    secure: true
    verify: true
```

</details>


### Supply Chain Controls (SC)

| Control | Config Path | Default | Verification |
|---------|-------------|---------|--------------|
| OSSASAI-SC-01 | `plugins.mode` | `"allowlist"` (L2+) | `openclaw security audit --check SC-01` |
| OSSASAI-SC-02 | `plugins.pinning` | `true` (L2 SHOULD, L3 MUST) | `openclaw security audit --check SC-02` |
| OSSASAI-SC-03 | `signing.verification` | `true` (L2 SHOULD, L3 MUST) | `openclaw security audit --check SC-03` |

<details>
<summary><strong>SC Control Configuration Details</strong></summary>

```yaml
# Supply Chain Controls

# SC-01: Plugin Trust (L2+)
plugins:
  mode: "allowlist"
  allowlist:
    - name: "official-git"
      publisher: "openclaw"
    - name: "official-npm"
      publisher: "openclaw"

# SC-02: Reproducible Builds (L2 SHOULD, L3 MUST)
plugins:
  pinning:
    enabled: true
    strategy: "exact"
  lockfile: "~/.openclaw/plugins.lock"

# SC-03: Artifact Signing (L2 SHOULD, L3 MUST)
signing:
  verification:
    enabled: true
    required: true  # L3
  methods:
    - type: "sigstore"
      trusted_identities:
        - email: "release@openclaw.ai"
```

</details>


### Formal Verification Controls (FV)

| Control | Config Path | Default | Verification |
|---------|-------------|---------|--------------|
| OSSASAI-FV-01 | `verification.invariants` | Optional (L3 SHOULD) | `openclaw security audit --check FV-01` |
| OSSASAI-FV-02 | `verification.negative_tests` | Optional (L3 SHOULD) | `openclaw security audit --check FV-02` |
| OSSASAI-FV-03 | `verification.ci_integration` | Optional (L3 SHOULD) | `openclaw security audit --check FV-03` |

<details>
<summary><strong>FV Control Configuration Details</strong></summary>

```yaml
# Formal Verification Controls (Optional, L3 SHOULD)

# FV-01: Security Invariants
verification:
  invariants:
    enabled: true
    definitions:
      - id: "sandbox_boundary"
        expression: "path.is_relative_to(sandbox_root)"

# FV-02: Negative Model Testing
verification:
  negative_tests:
    enabled: true
    models:
      - path: "models/sandbox_escape.tla"

# FV-03: CI Integration
verification:
  ci_integration:
    enabled: true
    run_on: ["push", "pr"]
```

</details>


### Network Security Controls (NS)

| Control | Config Path | Default | Verification |
|---------|-------------|---------|--------------|
| OSSASAI-NS-01 | `tls.required` | `true` (L2+) | `openclaw security audit --check NS-01` |
| OSSASAI-NS-02 | `tls.verify_certs` | `true` (L2+) | `openclaw security audit --check NS-02` |
| OSSASAI-NS-03 | `api.security` | See config | `openclaw security audit --check NS-03` |
| OSSASAI-NS-04 | `network.monitoring` | See config (L3) | `openclaw security audit --check NS-04` |

<details>
<summary><strong>NS Control Configuration Details</strong></summary>

```yaml
# Network Security Controls

# NS-01: TLS Enforcement (L2+)
tls:
  required: true
  min_version: "TLS1.2"
  cipher_suites:
    - "TLS_AES_256_GCM_SHA384"
    - "TLS_CHACHA20_POLY1305_SHA256"

# NS-02: Certificate Validation (L2+)
tls:
  verify_certs: true
  ca_bundle: "system"
  cert_pinning:  # L3 recommended
    enabled: true
    pins:
      - host: "api.openclaw.ai"
        sha256: "AAAA..."

# NS-03: API Security (L2+)
api:
  security:
    authentication: true
    rate_limiting:
      enabled: true
      requests_per_minute: 60

# NS-04: Traffic Analysis (L3)
network:
  monitoring:
    enabled: true
    anomaly_detection: true
    exfiltration_alerts: true
```

</details>


## Verification Tooling

### Audit Commands

```bash
# Run full compliance audit
openclaw security audit --level L2

# Check specific control
openclaw security audit --check CP-01

# Check entire domain
openclaw security audit --domain TB

# Generate JSON report
openclaw security audit --level L2 --output-format json > audit.json

# Generate compliance statement
openclaw security report --format yaml > compliance.yaml
```

### Evidence Collection

```bash
# Export configuration evidence
openclaw config export > evidence/config.yaml

# Generate plugin inventory
openclaw plugins list --format json > evidence/plugins.json

# Export audit logs
openclaw audit export --since "30d" > evidence/audit-logs.json

# Generate SBOM
openclaw plugins sbom --format spdx > evidence/sbom.json
```

## Conformance Recipes

### L1: Local-First Baseline


  1. **Install OpenClaw**

   ```bash
       # Install via package manager
       brew install openclaw  # macOS
       apt install openclaw   # Debian/Ubuntu
       ```

  2. **Initialize with Security Baseline**

   ```bash
       openclaw init --security-baseline
       ```

  3. **Verify Configuration**

   ```bash
       openclaw security audit --level L1
       ```

  4. **Start Agent**

   ```bash
       openclaw start
       ```


### L2: Network-Aware Deployment


  5. **Complete L1 Setup**

   Follow L1 steps above

  6. **Enable TLS**

   ```bash
       openclaw tls enable --generate-certs
       ```

  7. **Configure Authentication**

   ```bash
       openclaw auth setup --type token
       openclaw auth rotate  # Generate initial token
       ```

  8. **Enable Plugin Allowlist**

   ```bash
       openclaw plugins set-mode allowlist
       openclaw plugins trust official-*
       ```

  9. **Verify L2 Compliance**

   ```bash
       openclaw security audit --level L2
       ```


### L3: High-Assurance Deployment


  10. **Complete L2 Setup**

   Follow L2 steps above

  11. **Enable Artifact Signing**

   ```bash
       openclaw signing enable --sigstore
       ```

  12. **Configure Network Monitoring**

   ```bash
       openclaw monitor enable --anomaly-detection
       ```

  13. **Enable Formal Verification (Optional)**

   ```bash
       openclaw verification enable --invariants
       ```

  14. **Verify L3 Compliance**

   ```bash
       openclaw security audit --level L3
       ```


## Platform Extensions

OCSAS includes the following OpenClaw-specific extensions beyond OSSASAI core controls:

| Extension ID | Title | Description |
|--------------|-------|-------------|
| OCSAS-EXT-01 | MCP Server Security | Security controls for Model Context Protocol servers |
| OCSAS-EXT-02 | Hook Security | Security validation for pre/post execution hooks |
| OCSAS-EXT-03 | Memory Provider Security | Controls for RAG and memory provider integrations |

## Registry Configuration

OCSAS is registered with the OSSASAI Profile Registry and automatically receives notifications about framework changes.

### Profile Registration

```yaml
# OCSAS Registry Entry
profile:
  id: "OSSASAI-PROFILE-OPENCLAW-OCSAS-1.0.0"
  name: "OCSAS - OpenClaw Security Assurance Standard"
  platform: "openclaw"
  version: "1.0.0"
  ossasai_version: "0.2.0"
  ossasai_compatibility: ["0.1.0", "0.2.0"]
  status: "official"
  repository: "https://github.com/gensecaihq/ossasai"
  documentation: "https://ossasai.dev/profiles/openclaw"

maintainers:
  - name: "OSSASAI Project"
    email: "profiles@ossasai.dev"
    role: "lead"

webhooks:
  url: "https://ossasai.dev/internal/webhooks/ocsas"
  events: ["all"]
```

### Compatibility Status

| OSSASAI Version | OCSAS Version | Status |
|-----------------|---------------|--------|
| 0.2.0 | 1.0.0 | Fully Compatible |
| 0.1.0 | 1.0.0 | Compatible (GEN controls added) |

### Staying Updated

OCSAS maintainers receive automatic notifications for:
- New controls added to the framework
- Changes to existing control definitions
- Requirement level changes (SHOULD→MUST)
- Breaking changes requiring migration

To check OCSAS compatibility with the current framework:

```bash
curl https://ossasai.dev/api/v1/profiles/OSSASAI-PROFILE-OPENCLAW-OCSAS/compatibility
```

## References

- [Profile Registry](/profiles/registry)
- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OSSASAI Specification](/spec/overview)
- [OSSASAI Control Catalog](/controls/overview)
- [Implementation Guides](/implementation/quickstart)
