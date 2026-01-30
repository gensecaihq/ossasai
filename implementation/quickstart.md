---
layout: default
title: Implementation
nav_order: 5
has_children: true
description: 'Rapid secure deployment of OSSASAI controls'
permalink: /implementation/
---

## Overview

This guide provides a rapid path to implementing OSSASAI controls. Choose your assurance level and follow the corresponding checklist to achieve baseline compliance.

## Prerequisites

Before starting, ensure you have:

- [ ] AI assistant installed and configured
- [ ] Administrative access to configuration files
- [ ] Access to audit script: `curl -sSL https://raw.githubusercontent.com/gensecaihq/ossasai/main/tools/ossasai-audit.sh -o ossasai-audit.sh`
- [ ] Understanding of your [target assurance level](/spec/assurance-levels)

## Quick Assessment

Run the OSSASAI audit to determine your current security posture:

```bash
# Download audit script
curl -sSL https://raw.githubusercontent.com/gensecaihq/ossasai/main/tools/ossasai-audit.sh -o ossasai-audit.sh
chmod +x ossasai-audit.sh

# Run baseline assessment
./ossasai-audit.sh --level L1 --output-format json > baseline.json

# View summary
jq '.summary' baseline.json
```

## L1: Local-First (15-Minute Setup)


  1. **Configure Secure Defaults**

   Ensure your configuration file has these settings:
   
       ```yaml
       # config.yaml
       security:
         filesystem:
           scope: "workdir"
           follow_symlinks: false
         commands:
           require_approval: true
           mode: "allowlist"
         logging:
           enabled: true
       ```


  2. **Set Permission Boundaries**

   ```yaml
       permissions:
         filesystem:
           read:
             - "${workdir}/**"
           write:
             - "${workdir}/**"
           denied:
             - "**/.env*"
             - "**/*.key"
             - "**/*.pem"
         commands:
           allowed:
             - "git"
             - "npm"
             - "python"
       ```


  3. **Enable Authentication**

   ```yaml
       authentication:
         required: true
         method: "os_user"
         bind_to_euid: true
       ```


  4. **Verify**

   ```bash
       ./ossasai-audit.sh --level L1
       # All L1 controls should pass
       ```


### L1 Control Checklist

| Control | Setting | Verification |
|---------|---------|--------------|
| CP-01 | Secure defaults enabled | `./ossasai-audit.sh --check CP-01` |
| CP-02 | Permission model defined | `./ossasai-audit.sh --check CP-02` |
| ID-01 | Authentication required | `./ossasai-audit.sh --check ID-01` |
| TB-01 | Filesystem sandboxed | `./ossasai-audit.sh --check TB-01` |
| TB-02 | Commands allowlisted | `./ossasai-audit.sh --check TB-02` |
| LS-01 | Working directory isolated | `./ossasai-audit.sh --check LS-01` |
| LS-02 | Sensitive files protected | `./ossasai-audit.sh --check LS-02` |

---

## L2: Network-Aware (30-Minute Setup)

Includes all L1 controls plus network security.


  5. **Complete L1 Setup**

   Follow all L1 steps above first.


  6. **Enable TLS**

   ```yaml
       network:
         tls:
           required: true
           min_version: "TLS1.2"
         upgrade_insecure: true
       ```


  7. **Configure Session Isolation**

   ```yaml
       sessions:
         isolation:
           enabled: true
           per_session_storage: true
           cleanup_on_end: true
       ```


  8. **Enable Supply Chain Verification**

   ```yaml
       plugins:
         verification:
           enabled: true
           require_signature: true
   
       dependencies:
         integrity:
           enabled: true
           require_lockfile: true
       ```


  9. **Set Resource Limits**

   ```yaml
       resources:
         cpu:
           max_percent: 50
           max_time_seconds: 300
         memory:
           max_mb: 1024
         disk:
           max_file_size_mb: 100
       ```


  10. **Verify**

   ```bash
       ./ossasai-audit.sh --level L2
       # All L2 controls should pass
       ```


### L2 Additional Controls

| Control | Setting | Verification |
|---------|---------|--------------|
| CP-03 | Update verification | `./ossasai-audit.sh --check CP-03` |
| ID-02 | Session isolation | `./ossasai-audit.sh --check ID-02` |
| ID-03 | Secure credential storage | `./ossasai-audit.sh --check ID-03` |
| TB-03 | Resource limits | `./ossasai-audit.sh --check TB-03` |
| SC-01 | Plugin verification | `./ossasai-audit.sh --check SC-01` |
| SC-02 | Dependency integrity | `./ossasai-audit.sh --check SC-02` |
| NS-01 | TLS enforcement | `./ossasai-audit.sh --check NS-01` |
| NS-02 | Certificate validation | `./ossasai-audit.sh --check NS-02` |
| NS-03 | API security | `./ossasai-audit.sh --check NS-03` |

---

## L3: High-Assurance (Extended Setup)

L3 requires formal verification and enhanced monitoring.


  11. **Complete L2 Setup**

   Follow all L1 and L2 steps first.


  12. **Enable Configuration Tamper Detection**

   ```yaml
       integrity:
         enabled: true
         monitored_files:
           - config.yaml
           - permissions.yaml
         alert_on_change: true
       ```


  13. **Enable Artifact Signing**

   ```yaml
       signing:
         verification:
           enabled: true
           required: true
       ```


  14. **Define Security Invariants**

   ```yaml
       invariants:
         filesystem:
           - check: "path_within_sandbox"
             on_violation: "terminate"
         permissions:
           - check: "capability_bound"
             on_violation: "terminate"
       ```


  15. **Enable Network Monitoring**

   ```yaml
       monitoring:
         network:
           enabled: true
           track_destinations: true
           alert_on_unknown: true
       ```


  16. **Verify**

   ```bash
       ./ossasai-audit.sh --level L3
       # All L3 controls should pass
       ```


---

## Minimal Secure Configuration

Copy this configuration as a starting point:

```yaml
# ocsas-config.yaml - Minimal L2 Secure Configuration

version: "1.0"
assurance_level: "L2"

# Authentication (ID-01)
authentication:
  required: true
  method: "os_user"

# Filesystem Security (TB-01, LS-01, LS-02)
filesystem:
  scope: "workdir"
  follow_symlinks: false
  denied_patterns:
    - "**/.env*"
    - "**/*.key"
    - "**/*.pem"
    - "**/secrets/**"

# Command Execution (TB-02)
commands:
  mode: "allowlist"
  require_approval: true
  allowed:
    - command: "git"
    - command: "npm"
    - command: "python"
    - command: "make"

# Network Security (NS-01, NS-02, NS-03)
network:
  tls:
    required: true
    min_version: "TLS1.2"
  certificate_validation: true

# Session Security (ID-02)
sessions:
  isolation: true
  timeout_minutes: 60

# Resource Limits (TB-03)
resources:
  cpu_max_percent: 50
  memory_max_mb: 1024
  timeout_seconds: 300

# Supply Chain (SC-01, SC-02)
plugins:
  verification: true
dependencies:
  require_lockfile: true
  verify_integrity: true

# Logging (GEN-05)
logging:
  enabled: true
  level: "info"
  include_security_events: true
```

## Next Steps


  ### [L1 Deployment Guide](/implementation/l1-deployment)

Detailed guide for local-first deployments

  ### [L2 Deployment Guide](/implementation/l2-deployment)

Network-aware deployment with team features

  ### [Hardening Checklist](/implementation/hardening-checklist)

Comprehensive security hardening steps

  ### [CI/CD Integration](/implementation/ci-cd-integration)

Automate compliance verification


