---
layout: default
title: General (GEN)
parent: Controls
nav_order: 2
description: 'Cross-cutting foundational security controls applicable to all trust boundaries'
---

## Overview

General (GEN) controls represent foundational security principles that apply across all trust boundaries. These controls codify the core security architecture requirements that inform all other domain-specific controls.

> **Note:** General controls are the foundation upon which all other controls are built. Failure to implement these controls undermines the entire security architecture.

## OSSASAI-GEN-01: Security by Default

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-GEN-01 |
| **Requirement Level** | MUST |
| **Assurance Levels** | L1, L2, L3 |
| **Trust Boundary** | All |
| **OSSASAI Top 10** | #1 (Insecure defaults) |

### Requirement

Implementations MUST be secure in their default configuration. Security features MUST NOT require explicit opt-in by users. Default configurations MUST enable all applicable security controls without user intervention.

### Evidence

- Default configuration files demonstrating security-enabled settings
- Fresh installation audit reports showing baseline security compliance
- Documentation of default-secure behaviors

### Checks

- Fresh installation passes automated security audit without configuration changes
- All security controls are enabled by default
- No administrative action required to achieve baseline security

```bash
# Verification commands
# Test fresh installation security baseline
./ossasai-audit.sh --level L1 --config /dev/null
# Should report baseline controls passing

# Verify default configuration has security enabled
grep -E "enabled:\s*(true|yes)" /etc/ossasai/defaults.yaml
# Security features should be enabled by default

# Check that no explicit opt-in is required
./ossasai-audit.sh --check GEN-01 --fresh-install
```

### Remediation


  1. **Audit Default Configuration**

   Review all configuration defaults for security implications:
       ```yaml
       # Secure defaults template
       security:
         enabled: true  # MUST be true by default
   
       authentication:
         required: true  # MUST require auth by default
   
       sandbox:
         enabled: true  # MUST sandbox by default
   
       logging:
         security_events: true  # MUST log security events
       ```

  2. **Remove Opt-in Requirements**

   Ensure security features are enabled without user action:
       ```yaml
       # WRONG - requires opt-in
       security:
         enabled: false  # User must enable
   
       # CORRECT - secure by default
       security:
         enabled: true  # Already enabled
       ```

  3. **Verify Fresh Installation**

   Test that fresh installations are secure:
       ```bash
       # Reset to defaults and verify
       ./ossasai reset --factory-defaults
       ./ossasai-audit.sh --level L1
       # Should pass without configuration
       ```


### References

- NIST SP 800-123: Guide to General Server Security
- CIS Benchmark Methodology: Secure Configuration
- OWASP Secure Coding Practices: Security Defaults

---

## OSSASAI-GEN-02: Fail Secure

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-GEN-02 |
| **Requirement Level** | MUST |
| **Assurance Levels** | L1, L2, L3 |
| **Trust Boundary** | All |
| **OSSASAI Top 10** | #4 (Security bypass on error) |

### Requirement

Implementations MUST fail to a secure state when errors occur. Failures MUST NOT result in security control bypass. When unable to verify authorization, access MUST be denied. Error handling MUST NOT expose sensitive information.

### Evidence

- Error handling code review demonstrating fail-closed behavior
- Test results showing security maintained during fault conditions
- Configuration demonstrating fail-secure defaults

### Checks

- Inject faults in authentication, authorization, and sandboxing subsystems
- Security controls remain enforced during error conditions
- Partial system failures do not expose protected resources
- Error messages do not leak sensitive information

```bash
# Verification commands
# Test authentication failure behavior
curl -H "Authorization: Bearer INVALID" http://localhost:18789/api/admin
# Should return 401, not 500 or bypass

# Test service degradation
./ossasai-audit.sh --check GEN-02 --inject-faults

# Verify error responses don't leak info
curl -v http://localhost:18789/api/secret 2>&1 | grep -i "stack\|path\|internal"
# Should return empty (no internal details exposed)
```

### Remediation


  **Fail-Closed Configuration:**

Configure systems to deny access on failure:
    ```yaml
    security:
      on_auth_error: "deny"      # MUST deny, not allow
      on_policy_error: "deny"    # MUST deny, not allow
      on_timeout: "deny"         # MUST deny, not allow

    error_handling:
      expose_details: false      # Never expose internal errors
      log_details: true          # Log for debugging
      default_response: "deny"   # Default to denial
    ```


  **Graceful Degradation:**

Implement secure degradation when components fail:
    ```yaml
    resilience:
      # When sandbox unavailable, deny tool execution
      sandbox_unavailable: "block_tools"

      # When auth service unavailable, deny access
      auth_unavailable: "deny_access"

      # When logging unavailable, deny sensitive operations
      logging_unavailable: "deny_sensitive"

      # Recovery behavior
      recovery:
        auto_retry: true
        max_retries: 3
        backoff: "exponential"
    ```


  **Error Response Security:**

Sanitize error responses:
    ```yaml
    errors:
      # User-facing error format
      user_format:
        include_id: true          # For support reference
        include_details: false    # Never expose internals
        include_stack: false      # Never expose stack traces

      # Internal logging
      internal_format:
        include_details: true
        include_stack: true
        redact_secrets: true
    ```


### References

- OWASP Secure Coding Practices: Error Handling
- IEEE 1012-2016: Software Verification and Validation
- NIST SP 800-53 SI-11: Error Handling

---

## OSSASAI-GEN-03: Principle of Least Privilege

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-GEN-03 |
| **Requirement Level** | MUST |
| **Assurance Levels** | L1, L2, L3 |
| **Trust Boundary** | All |
| **OSSASAI Top 10** | #2 (Over-privileged tools) |

### Requirement

Implementations MUST operate with the minimum privileges necessary for intended functionality. Elevated privileges MUST be requested only when required and MUST be relinquished immediately after use. Default privilege sets MUST be restrictive.

### Evidence

- Runtime privilege audit showing minimal permissions
- Privilege escalation logs demonstrating scoped, time-bounded elevation
- Default role/permission configurations demonstrating restrictive defaults

### Checks

- Audit runtime privilege levels for all agent components
- Privilege escalation follows explicit request patterns
- Elevated privileges are time-bounded and scoped
- No persistent elevated privileges

```bash
# Verification commands
# Audit process privileges
ps aux | grep ossasai | awk '{print $1, $11}'
# Should not run as root

# Check file permissions
find /etc/ossasai -type f -perm /077 -ls
# Should return empty (no world-writable configs)

# Verify tool privileges
./ossasai-audit.sh --check GEN-03 --audit-privileges
```

### Remediation


  **Minimal Default Permissions:**

Configure restrictive default permissions:
    ```yaml
    permissions:
      default_policy: "deny"  # Deny by default

      # Agent runtime permissions
      agent:
        filesystem:
          read: ["${workdir}"]     # Only working directory
          write: ["${workdir}"]    # Only working directory
          execute: []              # No execution by default

        network:
          outbound: ["allowlist"]  # Only approved endpoints
          inbound: []              # No inbound by default

        system:
          processes: false         # Cannot spawn processes
          environment: false       # Cannot read env vars
    ```


  **Privilege Escalation Controls:**

Implement controlled privilege escalation:
    ```yaml
    privilege_escalation:
      # Require explicit request
      require_justification: true

      # Time-bounded elevation
      max_duration: "5m"
      auto_revoke: true

      # Scope limits
      scope:
        max_permissions: ["files.write:${workdir}"]
        forbidden: ["admin.*", "system.*"]

      # Approval requirements
      approval:
        required_for: ["network.external", "files.sensitive"]
        approver: "operator"
    ```


  **Runtime Privilege Audit:**

Enable privilege auditing:
    ```yaml
    audit:
      privilege_changes:
        log: true
        alert_on_escalation: true

      periodic_review:
        enabled: true
        interval: "24h"
        report_unused: true

      violations:
        log: true
        alert: true
        block: true
    ```


### References

- NIST SP 800-53 AC-6: Least Privilege
- Saltzer & Schroeder (1975): Protection of Information in Computer Systems
- CIS Controls 6.8: Define and Maintain Role-Based Access Control

---

## OSSASAI-GEN-04: Defense in Depth

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-GEN-04 |
| **Requirement Level** | SHOULD (L1), MUST (L2, L3) |
| **Assurance Levels** | L1 (SHOULD), L2 (MUST), L3 (MUST) |
| **Trust Boundary** | All |
| **OSSASAI Top 10** | #5 (Single point of failure) |

### Requirement

Implementations SHOULD (L1) / MUST (L2/L3) implement multiple independent layers of security controls. No single control failure SHOULD result in complete security bypass. Critical security functions MUST have redundant controls at L2/L3.

### Evidence

- Security architecture documentation showing layered controls
- Control dependency analysis demonstrating independence
- Failure mode analysis showing no single points of failure

### Checks

- Analyze control dependencies and identify single points of failure
- Redundant controls exist for critical security functions
- Disabling individual controls does not fully compromise security

```bash
# Verification commands
# Test layered authentication
./ossasai-audit.sh --check GEN-04 --test-layers

# Verify control independence
./ossasai-audit.sh --analyze-dependencies

# Test with individual controls disabled
for control in CP-01 TB-01 ID-01; do
  ./ossasai-audit.sh --disable-control $control --verify-residual-security
done
```

### Remediation


  **Layered Architecture:**

Implement multiple security layers:
    ```yaml
    defense_layers:
      # Layer 1: Network perimeter
      network:
        firewall: true
        tls_required: true
        rate_limiting: true

      # Layer 2: Authentication
      authentication:
        primary: "token"
        secondary: "mfa"        # L2/L3
        session_binding: true

      # Layer 3: Authorization
      authorization:
        rbac: true
        abac: true              # L3
        policy_engine: true

      # Layer 4: Application
      application:
        input_validation: true
        output_encoding: true
        sandbox: true

      # Layer 5: Data
      data:
        encryption_at_rest: true
        encryption_in_transit: true
        access_logging: true
    ```


  **Control Redundancy:**

Ensure redundant controls for critical functions:
    ```yaml
    redundancy:
      authentication:
        primary: "oidc"
        fallback: "local_token"
        backup: "emergency_access"

      authorization:
        policy_engines:
          - type: "opa"
            priority: 1
          - type: "builtin"
            priority: 2

      sandbox:
        primary: "container"
        secondary: "seccomp"
        tertiary: "apparmor"
    ```


  **Failure Mode Analysis:**

Document and test failure modes:
    ```yaml
    failure_analysis:
      controls:
        - id: "CP-01"
          failure_impact: "Admin interface exposed"
          mitigating_controls: ["NS-01", "CP-02"]
          residual_risk: "medium"

        - id: "TB-01"
          failure_impact: "Unrestricted tool access"
          mitigating_controls: ["TB-02", "GEN-03"]
          residual_risk: "high"
          requires_redundancy: true

      validation:
        test_individual_failures: true
        test_cascading_failures: true
        document_residual_risk: true
    ```


### References

- NSA Defense in Depth Strategy
- NIST SP 800-53 SC-3: Security Function Isolation
- ISO/IEC 27001 A.13: Communications Security

---

## OSSASAI-GEN-05: Audit Logging

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-GEN-05 |
| **Requirement Level** | SHOULD (L1), MUST (L2, L3) |
| **Assurance Levels** | L1 (SHOULD), L2 (MUST), L3 (MUST) |
| **Trust Boundary** | All |
| **OSSASAI Top 10** | #9 (No action ledger / weak approvals) |

### Requirement

Implementations SHOULD (L1) / MUST (L2/L3) maintain comprehensive audit logs of security-relevant events. Logs MUST include sufficient detail for forensic analysis. Logs MUST be tamper-evident at L3. Log integrity MUST be protected from modification by the agent.

### Evidence

- Audit log samples demonstrating captured security events
- Log retention configuration and verification
- At L3: Cryptographic log integrity verification

### Checks

- Audit log generation for all security-relevant events
- Log retention mechanisms operational
- Access controls prevent unauthorized log modification
- At L3: Cryptographic integrity verification passes

```bash
# Verification commands
# Verify audit logging is active
./ossasai-audit.sh --check GEN-05 --verify-logging

# Check log retention
find /var/log/ossasai -type f -mtime +90 | wc -l
# Should show retained logs based on policy

# Verify log integrity (L3)
./ossasai-audit.sh --check GEN-05 --verify-integrity

# Test log tampering detection
./ossasai-audit.sh --check GEN-05 --tamper-test
```

### Remediation


  **Comprehensive Logging:**

Configure complete security event logging:
    ```yaml
    audit:
      enabled: true

      # Events to capture
      events:
        authentication:
          - "login_attempt"
          - "login_success"
          - "login_failure"
          - "logout"
          - "session_created"
          - "session_expired"

        authorization:
          - "access_granted"
          - "access_denied"
          - "privilege_escalation"
          - "privilege_revoked"

        tools:
          - "tool_invocation"
          - "tool_approval_requested"
          - "tool_approval_granted"
          - "tool_approval_denied"
          - "tool_execution_complete"
          - "tool_execution_error"

        data:
          - "secret_accessed"
          - "file_read"
          - "file_write"
          - "data_export"

        configuration:
          - "config_changed"
          - "policy_updated"
          - "control_disabled"

      # Log format
      format:
        timestamp: "iso8601"
        include_request_id: true
        include_session_id: true
        include_user_id: true
        include_source_ip: true
    ```


  **Log Protection:**

Protect logs from tampering:
    ```yaml
    audit:
      protection:
        # Write permissions
        permissions:
          owner: "root"
          group: "ossasai-audit"
          mode: "0640"

        # Append-only mode
        append_only: true

        # Separate storage
        storage:
          path: "/var/log/ossasai/audit"
          separate_partition: true  # L3

        # Access controls
        access:
          read: ["security-team", "auditors"]
          write: []  # No write access
          delete: []  # No delete access
    ```


  **Tamper Evidence (L3):**

Implement cryptographic log integrity:
    ```yaml
    audit:
      integrity:
        enabled: true  # Required for L3

        # Hash chain
        hash_chain:
          algorithm: "sha256"
          chain_interval: "1m"

        # Digital signatures
        signatures:
          enabled: true
          key_type: "ed25519"
          key_storage: "hsm"  # Recommended
          sign_interval: "5m"

        # External anchoring
        anchoring:
          enabled: true
          service: "timestamping_authority"
          interval: "1h"

        # Verification
        verification:
          on_startup: true
          periodic: true
          interval: "6h"
          alert_on_failure: true
    ```


  **Log Retention:**

Configure appropriate retention:
    ```yaml
    audit:
      retention:
        # Minimum retention periods
        security_events: "365d"    # 1 year minimum
        access_logs: "90d"
        tool_invocations: "180d"

        # Storage management
        rotation:
          max_size: "100MB"
          compress: true

        # Archival
        archive:
          enabled: true
          destination: "s3://audit-archive"
          encryption: true

        # Deletion
        deletion:
          require_approval: true
          audit_deletion: true
    ```


### References

- NIST SP 800-92: Guide to Computer Security Log Management
- SOC 2 Type II CC6.1: Logical and Physical Access Controls
- ISO/IEC 27001 A.12.4: Logging and Monitoring
- OWASP Logging Cheat Sheet
