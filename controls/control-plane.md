---
layout: default
title: Control Plane (CP)
parent: Controls
nav_order: 3
description: 'B2 boundary controls for admin access, exposure, and authentication'
---

## Overview

Control Plane (CP) controls govern the B2 trust boundary—admin access to configuration and approvals via UI, API, or CLI. These controls address the "exposed control plane / weak admin auth" failure mode (OSSASAI Top 10 #3).

> **Note:** Control-plane interfaces are high-value targets. Unauthorized access to the control plane bypasses most other security controls.

## OSSASAI-CP-01: Default-deny Exposure

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-CP-01 |
| **Requirement Level** | MUST |
| **Assurance Levels** | L1, L2, L3 |
| **Trust Boundary** | B2 (Control Plane) |
| **OSSASAI Top 10** | #3 (Exposed control plane) |

### Requirement

Control-plane interfaces MUST default to non-public exposure (loopback/private network) unless explicitly enabled.

### Evidence

- Bind configuration showing localhost/private network binding
- Network topology notes documenting exposure

### Checks

- Scanner confirms no public routes to admin UI/API
- Network audit shows control plane not reachable from untrusted networks

```bash
# Verification commands
netstat -tlnp | grep -E ":(18789|8080)" | grep -v "127.0.0.1"
# Should return empty if properly configured

nmap -p 18789 <public-ip>
# Should show port filtered/closed
```

### Remediation


  1. **Restrict Binding**

   Configure control plane to bind to localhost only:
       ```yaml
       gateway:
         bind: "127.0.0.1:18789"  # Loopback only
       ```

  2. **Use VPN/Tailnet**

   For remote access, use VPN, tailnet, or SSH tunnel instead of public exposure:
       ```bash
       # SSH tunnel example
       ssh -L 18789:localhost:18789 user@server
       ```

  3. **Verify Exposure**

   Run security audit to confirm:
       ```bash
       openclaw security audit --deep
       ```


### References

- OWASP ASVS V1.4.1: Access Control Architecture
- CIS Controls 4.4: Implement and Manage a Firewall on Servers
- NIST SP 800-53 SC-7: Boundary Protection

---

## OSSASAI-CP-02: Strong Admin Authentication

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-CP-02 |
| **Requirement Level** | MUST |
| **Assurance Levels** | L1, L2, L3 |
| **Trust Boundary** | B2 (Control Plane) |
| **OSSASAI Top 10** | #3 (Weak admin auth) |

### Requirement

Control-plane access MUST require strong authentication (token, SSO, or mTLS). Shared passwords SHOULD be avoided.

### Evidence

- Auth configuration showing required authentication
- Rotation logs demonstrating credential lifecycle management

### Checks

- Automated probe confirms auth required for handshake and requests
- Unauthenticated requests are rejected

```bash
# Test unauthenticated access
curl -s http://localhost:18789/api/status
# Should return 401 Unauthorized

# Test with invalid token
curl -s -H "Authorization: Bearer invalid" http://localhost:18789/api/status
# Should return 401 Unauthorized
```

### Remediation


  **Token Authentication:**

```yaml
    auth:
      type: "token"
      token_rotation_days: 30
      require_on_handshake: true
    ```

    Generate and rotate tokens:
    ```bash
    openclaw auth rotate
    openclaw auth show-token
    ```


  **SSO/OIDC:**

```yaml
    auth:
      type: "oidc"
      issuer: "https://accounts.google.com"
      client_id: "${OIDC_CLIENT_ID}"
      allowed_domains:
        - "example.com"
    ```


  **mTLS:**

```yaml
    auth:
      type: "mtls"
      ca_cert: "/path/to/ca.crt"
      require_client_cert: true
    ```


### References

- OWASP ASVS V2: Authentication
- NIST SP 800-63B: Digital Identity Guidelines
- CIS Controls 5.2: Use Unique Passwords

---

## OSSASAI-CP-03: Proxy Trust Boundary Correctness

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-CP-03 |
| **Requirement Level** | MUST |
| **Assurance Levels** | L2, L3 |
| **Trust Boundary** | B2 (Control Plane) |
| **OSSASAI Top 10** | #3 (Exposed control plane) |

### Requirement

When using reverse proxies, systems MUST correctly handle trusted proxies and overwrite forwarded headers to prevent spoofing.

### Evidence

- Proxy configuration showing trusted proxy settings
- Trusted proxy list documentation

### Checks

- Spoof tests (XFF/XFP) fail closed
- Requests with spoofed headers from untrusted sources are rejected or headers are overwritten

```bash
# Test header spoofing from untrusted source
curl -H "X-Forwarded-For: 1.2.3.4" http://localhost:18789/api/whoami
# Should NOT trust the spoofed IP

# Test from trusted proxy (should work)
curl --proxy http://trusted-proxy:8080 http://localhost:18789/api/whoami
```

### Remediation


  4. **Configure Trusted Proxies**

   ```yaml
       gateway:
         trustedProxies:
           - "127.0.0.1"
           - "10.0.0.0/8"      # Internal network
           - "172.16.0.0/12"   # Docker networks
       ```

  5. **Verify Header Handling**

   Ensure the application:
       - Only trusts X-Forwarded-* headers from listed proxies
       - Overwrites headers from untrusted sources
       - Logs spoofing attempts

  6. **Test Configuration**

   ```bash
       openclaw security audit --check proxy-trust
       ```


### References

- OWASP: HTTP Host Header Attacks
- RFC 7239: Forwarded HTTP Extension
- NIST SP 800-53 SC-8: Transmission Confidentiality and Integrity

---

## OSSASAI-CP-04: Separation of Operator vs Agent Identities

### Metadata

| Attribute | Value |
|-----------|-------|
| **Control ID** | OSSASAI-CP-04 |
| **Requirement Level** | MUST |
| **Assurance Levels** | L2, L3 |
| **Trust Boundary** | B2 (Control Plane) |
| **OSSASAI Top 10** | #2 (Over-privileged tools) |

### Requirement

Operator/admin identities MUST be distinct from agent-run identities and tokens. Agent tokens MUST have minimal scopes required for operation.

### Evidence

- Identity map showing distinct operator and agent accounts
- Token scopes documentation demonstrating least privilege

### Checks

- Least-privilege token review
- Agent tokens cannot perform admin operations
- Operator tokens are not used for agent runtime operations

```bash
# Check agent token scopes
openclaw auth show-scopes --token agent
# Should show minimal scopes: tools.execute, files.read, etc.

# Verify agent token cannot admin
curl -H "Authorization: Bearer $AGENT_TOKEN" \
  http://localhost:18789/api/admin/config
# Should return 403 Forbidden
```

### Remediation


  **Create Separate Identities:**

```bash
    # Create operator identity (full access)
    openclaw auth create-identity --role operator --name "admin@example.com"

    # Create agent identity (minimal scopes)
    openclaw auth create-identity --role agent --name "agent-runtime" \
      --scopes "tools.execute,files.read,files.write:workdir"
    ```


  **Configure Scope Restrictions:**

```yaml
    identities:
      operator:
        type: "human"
        scopes: ["admin.*", "config.*", "audit.*"]
      agent:
        type: "service"
        scopes:
          - "tools.execute"
          - "files.read:${workdir}"
          - "files.write:${workdir}"
          - "network.fetch:allowlist"
    ```


  **Audit Identity Usage:**

```bash
    # Review identity usage
    openclaw audit logs --filter "identity_type=agent" --action "admin.*"
    # Should return empty - agents shouldn't perform admin actions
    ```


### References

- OWASP ASVS V4.1: General Access Control
- NIST SP 800-53 AC-6: Least Privilege
- CIS Controls 6.8: Define and Maintain Role-Based Access Control
