---
layout: default
title: Supply Chain (SC)
parent: Controls
nav_order: 7
description: 'Extension and plugin security controls for trust, inventory, and pinning'
---

## Overview

Supply Chain (SC) controls address the security of extensions, plugins, and skills that expand agent capabilities. These controls address "plugin/skill supply chain risk" (OSSASAI Top 10 #7).

> **Note:** Extensions run with significant privileges within the agent runtime. Unreviewed plugins can introduce malware, exfiltrate data, or compromise the control plane.

## OSSASAI-SC-01: Explicit Plugin Trust + Inventory

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-SC-01 |
| **Requirement Level** | MUST |
| **Assurance Levels** | L2, L3 |
| **Trust Boundary** | Cross-cutting |
| **OSSASAI Top 10** | #7 (Extension supply chain) |

### Requirement

Extensions/plugins MUST be explicitly trusted; the system MUST provide an inventory and SHOULD support allowlists.

### Evidence

- Inventory snapshot showing all installed extensions
- Allowlist configuration

### Checks

- Unknown plugins flagged during audit
- Hashes/signatures verified if supported

```bash
# List all installed plugins
openclaw plugins list

# Verify plugin integrity
openclaw plugins verify

# Check for unknown/untrusted plugins
openclaw security audit --check plugins
# Should report: "All plugins in allowlist" or flag unknown ones
```

### Remediation


  **Configure Allowlist:**

```yaml
    plugins:
      # Only allow explicitly listed plugins
      mode: "allowlist"

      allowlist:
        - name: "official-git"
          publisher: "ossasai"
          min_version: "1.0.0"

        - name: "official-npm"
          publisher: "ossasai"
          min_version: "1.0.0"

        - name: "code-search"
          publisher: "verified-vendor"
          min_version: "2.1.0"

      # Block these regardless of other settings
      blocklist:
        - name: "known-malicious-plugin"
        - publisher: "untrusted-publisher"
    ```


  **Maintain Inventory:**

```bash
    # Export current plugin inventory
    openclaw plugins list --format json > evidence/plugin-inventory.json

    # Compare against baseline
    diff evidence/plugin-inventory.json evidence/baseline-inventory.json

    # Generate inventory report
    openclaw plugins inventory --output evidence/inventory-report.md
    ```

    Inventory should include:
    - Plugin name and version
    - Publisher/source
    - Installation date
    - Hash/signature (if available)
    - Permissions requested
    - Last update check


  **Review Process:**

Before adding new plugins:

    ```yaml
    plugin_review:
      checklist:
        - source_verified: true
        - publisher_trusted: true
        - code_reviewed: true  # For high-privilege plugins
        - permissions_appropriate: true
        - no_excessive_network: true
        - no_obfuscation: true

      approval:
        required_for: "all"
        approver: "security-team"
        documentation: "required"
    ```

    ```bash
    # Review plugin before installation
    openclaw plugins review <plugin-name>

    # Install with explicit trust
    openclaw plugins install <plugin-name> --trust --approved-by "admin@example.com"
    ```


### References

- SLSA v1.0: Supply-chain Levels for Software Artifacts
- NIST SP 800-53 SA-12: Supply Chain Risk Management
- CIS Controls 2.5: Allowlist Authorized Software

---

## OSSASAI-SC-02: Reproducible Builds / Pinning

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-SC-02 |
| **Requirement Level** | SHOULD (L2), MUST (L3) |
| **Assurance Levels** | L2 (SHOULD), L3 (MUST) |
| **Trust Boundary** | Cross-cutting |
| **OSSASAI Top 10** | #7 (Extension supply chain) |

### Requirement

High-assurance deployments SHOULD pin plugin versions and SHOULD prefer reproducible builds or signed artifacts.

### Evidence

- Lockfiles showing pinned versions
- Signature verification logs

### Checks

- SBOM (Software Bill of Materials) available
- Integrity checks pass for all plugins

```bash
# Verify pinned versions
openclaw plugins verify --check-pinning

# Verify signatures
openclaw plugins verify --check-signatures

# Generate SBOM
openclaw plugins sbom --format spdx > evidence/sbom.spdx.json
```

### Remediation


  **Pin Plugin Versions:**

```yaml
    plugins:
      pinning:
        enabled: true
        strategy: "exact"  # or "semver-minor"

      pinned:
        - name: "official-git"
          version: "1.2.3"
          sha256: "abc123def456..."

        - name: "official-npm"
          version: "2.0.1"
          sha256: "789xyz012abc..."

      # Lockfile location
      lockfile: "~/.openclaw/plugins.lock"
    ```

    ```bash
    # Generate lockfile from current state
    openclaw plugins lock

    # Update lockfile
    openclaw plugins lock --update

    # Verify against lockfile
    openclaw plugins verify --lockfile
    ```


  **Signature Verification:**

```yaml
    plugins:
      signatures:
        required: true  # L3: MUST require signatures

        trust_anchors:
          - type: "pgp"
            key_id: "OSSASAI-SIGNING-KEY"
            key_url: "https://ossasai.dev/keys/plugins.asc"

          - type: "sigstore"
            issuer: "https://accounts.google.com"
            identity: "plugins@ossasai.dev"

        # On signature failure
        on_failure: "block"  # or "warn"
    ```

    ```bash
    # Verify plugin signatures
    openclaw plugins verify --signatures

    # Import signing key
    openclaw plugins trust-key --key-url https://ossasai.dev/keys/plugins.asc

    # Verify specific plugin
    openclaw plugins verify <plugin-name> --signature
    ```


  **Reproducible Builds:**

For L3 deployments:

    ```yaml
    plugins:
      reproducible:
        enabled: true

        # Build verification
        verify_builds: true
        rebuild_to_verify: false  # Set true for paranoid mode

        # Source requirements
        source:
          require_source_available: true
          require_build_instructions: true

        # Artifact storage
        artifacts:
          store_locally: true
          verify_on_load: true
    ```

    ```bash
    # Verify reproducible build
    openclaw plugins verify --reproducible <plugin-name>

    # Build from source
    openclaw plugins build --from-source <plugin-name>

    # Compare with published artifact
    openclaw plugins compare-build <plugin-name>
    ```


### References

- SLSA v1.0: Build Requirements
- Reproducible Builds Project
- NIST SP 800-53 SA-10: Developer Configuration Management

---

## OSSASAI-SC-03: Artifact Signing and Attestation

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-SC-03 |
| **Requirement Level** | SHOULD (L2), MUST (L3) |
| **Assurance Levels** | L2 (SHOULD), L3 (MUST) |
| **Trust Boundary** | Cross-cutting |
| **OSSASAI Top 10** | #7 (Extension supply chain) |

### Requirement

High-assurance deployments SHOULD (L2) / MUST (L3) verify cryptographic signatures on plugins, updates, and binary artifacts before installation or execution. Signature verification failures MUST block artifact use at L3.

### Evidence

- Signature verification configuration showing trusted keys/identities
- Verification logs demonstrating signature checks on artifact installation
- Trusted key/identity inventory documentation

### Checks

- Signed artifacts pass verification
- Unsigned artifacts are rejected (L3) or warned (L2)
- Invalid signatures are rejected at all levels
- Key/identity trust chain is documented

```bash
# Verification commands
# Verify plugin signatures
openclaw plugins verify --signatures

# Check Sigstore verification
cosign verify-blob --signature plugin.sig --certificate plugin.crt plugin.tar.gz

# Verify PGP signatures
gpg --verify plugin.sig plugin.tar.gz

# Test rejection of unsigned artifacts
openclaw plugins install unsigned-plugin
# Should fail at L3, warn at L2
```

### Remediation


  **Sigstore Verification:**

Configure Sigstore/Cosign verification:
    ```yaml
    signing:
      verification:
        enabled: true
        required: true  # MUST for L3

      methods:
        - type: "sigstore"
          rekor_url: "https://rekor.sigstore.dev"
          fulcio_url: "https://fulcio.sigstore.dev"

          trusted_identities:
            - email: "release@ossasai.dev"
              issuer: "https://accounts.google.com"
            - email: "plugins@verified-vendor.com"
              issuer: "https://token.actions.githubusercontent.com"
              subject_claim: "repo:verified-vendor/plugin:ref:refs/heads/main"

          # SLSA attestation verification
          attestation:
            require_slsa: true
            minimum_level: "slsa3"  # L3 recommended
    ```

    ```bash
    # Verify with Cosign
    cosign verify \
      --certificate-identity release@ossasai.dev \
      --certificate-oidc-issuer https://accounts.google.com \
      ghcr.io/ossasai/plugin:latest

    # Verify SLSA attestation
    slsa-verifier verify-artifact plugin.tar.gz \
      --provenance-path plugin.intoto.jsonl \
      --source-uri github.com/ossasai/plugin
    ```


  **PGP Verification:**

Configure PGP signature verification:
    ```yaml
    signing:
      methods:
        - type: "pgp"
          keyserver: "hkps://keys.openpgp.org"

          trusted_keys:
            - id: "OSSASAI-RELEASE-KEY"
              fingerprint: "1234 5678 9ABC DEF0 1234 5678 9ABC DEF0 1234 5678"
              url: "https://ossasai.dev/keys/release.asc"

            - id: "VENDOR-PLUGIN-KEY"
              fingerprint: "ABCD EF01 2345 6789 ABCD EF01 2345 6789 ABCD EF01"

          verification:
            require_trusted_key: true
            check_expiration: true
            check_revocation: true
    ```

    ```bash
    # Import trusted keys
    curl -sSL https://ossasai.dev/keys/release.asc | gpg --import

    # Verify signature
    gpg --verify plugin.tar.gz.asc plugin.tar.gz

    # Check key trust
    gpg --list-keys --with-colons | grep -E "^pub.*:f:"
    ```


  **Artifact Policy:**

Configure artifact acceptance policy:
    ```yaml
    signing:
      artifacts:
        plugins:
          signature_required: true    # Always require for plugins
          allowed_signers:
            - "ossasai-official"
            - "verified-vendors"

        updates:
          signature_required: true    # Always require for updates
          allowed_signers:
            - "ossasai-official"

        dependencies:
          signature_required: false   # Use integrity hashes
          integrity_required: true
          lockfile_required: true

      # Enforcement behavior
      enforcement:
        on_missing_signature:
          L2: "warn"
          L3: "block"
        on_invalid_signature:
          all: "block"
        on_untrusted_signer:
          L2: "warn"
          L3: "block"
        on_expired_signature:
          all: "block"
    ```


  **Key Management:**

Establish key management procedures:
    ```yaml
    signing:
      key_management:
        # Key rotation
        rotation:
          schedule: "annual"
          overlap_period: "30d"
          notify_before: "60d"

        # Key storage (L3)
        storage:
          type: "hsm"  # Recommended for L3
          backup: "encrypted_offline"

        # Trust establishment
        trust:
          ceremony_required: true
          witnesses_required: 2
          document_chain: true

        # Revocation
        revocation:
          publish_to: ["keyserver", "website"]
          notify_dependents: true
          grace_period: "7d"
    ```

    ```bash
    # Generate signing key (offline machine)
    gpg --full-generate-key --expert

    # Export public key
    gpg --armor --export KEYID > release.asc

    # Publish to keyserver
    gpg --send-keys KEYID

    # Create revocation certificate (store securely)
    gpg --gen-revoke KEYID > revoke.asc
    ```


### References

- SLSA v1.0: Supply-chain Levels for Software Artifacts
- Sigstore: Software Signing Made Easy
- NIST SP 800-53 SA-12: Supply Chain Risk Management
- The Update Framework (TUF) Specification
