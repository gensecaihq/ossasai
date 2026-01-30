---
title: 'Evidence Collection'
description: 'Required evidence artifacts for OSSASAI compliance'
---

## Overview

Evidence collection documents the implementation of OSSASAI controls. This guide specifies required artifacts for each control.

## Evidence Types

| Type | Description | Examples |
|------|-------------|----------|
| Configuration | System settings | Config files, policies |
| Documentation | Procedures and designs | Architecture docs |
| Test Results | Verification outputs | Audit reports, test logs |
| Logs | Runtime evidence | Security logs, alerts |
| Screenshots | Visual evidence | UI configurations |

## Evidence by Control

### Control Plane (CP)

<details>
<summary><strong>CP-01: Secure Default Configuration</strong></summary>

**Required Evidence:**
- [ ] Default configuration file
- [ ] Security settings documentation
- [ ] Test showing blocked operation with defaults

**Example:**
```yaml
# evidence/cp-01/
├── default-config.yaml
├── security-defaults-doc.md
└── test-results.json
```

</details>


<details>
<summary><strong>CP-02: Permission Model Enforcement</strong></summary>

**Required Evidence:**
- [ ] Permission policy file
- [ ] Permission model documentation
- [ ] Test results for boundary enforcement

**Example:**
```yaml
# evidence/cp-02/
├── permissions.yaml
├── permission-model.md
├── boundary-tests.json
└── bypass-test-results.json
```

</details>


<details>
<summary><strong>CP-03: Update Integrity Verification</strong></summary>

**Required Evidence:**
- [ ] Update configuration
- [ ] Trusted key list
- [ ] Test with valid/invalid signatures

**Example:**
```yaml
# evidence/cp-03/
├── update-config.yaml
├── trusted-keys.asc
├── valid-signature-test.log
└── invalid-signature-test.log
```

</details>


### Identity & Session (ID)

<details>
<summary><strong>ID-01: Local Authentication</strong></summary>

**Required Evidence:**
- [ ] Authentication configuration
- [ ] Test results: no-auth denied, root denied

**Example:**
```yaml
# evidence/id-01/
├── auth-config.yaml
├── no-auth-test.log
├── root-denied-test.log
└── valid-auth-test.log
```

</details>


<details>
<summary><strong>ID-02: Session Isolation</strong></summary>

**Required Evidence:**
- [ ] Session configuration
- [ ] Isolation test procedure
- [ ] Cross-session access test results

**Example:**
```yaml
# evidence/id-02/
├── session-config.yaml
├── isolation-test-procedure.md
├── cross-session-tests.json
└── session-cleanup-verification.log
```

</details>


### Tool Blast Radius (TB)

<details>
<summary><strong>TB-01: Filesystem Sandboxing</strong></summary>

**Required Evidence:**
- [ ] Sandbox configuration
- [ ] Path traversal test results
- [ ] Symlink escape test results

**Example:**
```yaml
# evidence/tb-01/
├── sandbox-config.yaml
├── path-traversal-tests.json
├── symlink-tests.json
└── boundary-test-summary.md
```

</details>


<details>
<summary><strong>TB-02: Command Execution Restrictions</strong></summary>

**Required Evidence:**
- [ ] Command allowlist
- [ ] Command denylist
- [ ] Injection test results

**Example:**
```yaml
# evidence/tb-02/
├── command-allowlist.yaml
├── command-denylist.yaml
├── injection-tests.json
└── metacharacter-tests.json
```

</details>


### Supply Chain (SC)

<details>
<summary><strong>SC-02: Dependency Integrity Checking</strong></summary>

**Required Evidence:**
- [ ] Lockfiles (package-lock.json, etc.)
- [ ] SBOM (CycloneDX or SPDX format)
- [ ] Vulnerability scan results

**Example:**
```yaml
# evidence/sc-02/
├── package-lock.json
├── sbom.json
├── vulnerability-scan.json
└── integrity-check.log
```

</details>


### Network Security (NS)

<details>
<summary><strong>NS-01: TLS Enforcement</strong></summary>

**Required Evidence:**
- [ ] TLS configuration
- [ ] SSL scan results (SSL Labs or testssl.sh)

**Example:**
```yaml
# evidence/ns-01/
├── tls-config.yaml
├── ssl-labs-report.pdf
└── testssl-output.txt
```

</details>


## Evidence Package Structure

```
evidence/
├── manifest.yaml           # Evidence index
├── scope.yaml              # Assessment scope
├── cp/
│   ├── cp-01/
│   ├── cp-02/
│   ├── cp-03/
│   └── cp-04/
├── id/
│   ├── id-01/
│   ├── id-02/
│   └── id-03/
├── tb/
│   ├── tb-01/
│   ├── tb-02/
│   └── tb-03/
├── ls/
│   ├── ls-01/
│   ├── ls-02/
│   └── ls-03/
├── sc/
│   ├── sc-01/
│   ├── sc-02/
│   └── sc-03/
├── fv/                     # L3 only
│   ├── fv-01/
│   ├── fv-02/
│   └── fv-03/
├── ns/
│   ├── ns-01/
│   ├── ns-02/
│   ├── ns-03/
│   └── ns-04/
└── summary/
    ├── compliance-report.json
    └── attestation.yaml
```

## Evidence Manifest

```yaml
# evidence/manifest.yaml
manifest:
  version: "1.0"
  assessment_date: "2026-01-15"
  target_level: "L2"

evidence:
  - control: "CP-01"
    artifacts:
      - path: "cp/cp-01/default-config.yaml"
        type: "configuration"
        description: "Default security configuration"
      - path: "cp/cp-01/test-results.json"
        type: "test_results"
        description: "Automated audit results"
    status: "complete"

  - control: "TB-01"
    artifacts:
      - path: "tb/tb-01/sandbox-config.yaml"
        type: "configuration"
      - path: "tb/tb-01/boundary-tests.json"
        type: "test_results"
    status: "complete"
```

## Evidence Retention

| Evidence Type | Retention Period | Storage |
|---------------|------------------|---------|
| Configuration | Current + 2 versions | Version control |
| Test Results | 2 years | Secure archive |
| Audit Logs | Per regulatory requirement | SIEM/archive |
| Certifications | Until superseded | Secure storage |
