# OSSASAI - Open Security Standard for Agentic Systems

[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-0.1.0-blue)](CHANGELOG.md)

**OSSASAI** is a security framework for AI agents — the bots that can run commands, browse the web, and access your files. It tells you what security controls to look for and how to verify they're working.

---

## What Is This? (Simple Explanation)

AI agents are powerful but risky. They can:
- Execute shell commands on your computer
- Read and write your files
- Browse the web and fill out forms
- Send messages to your contacts

**OSSASAI** is a checklist that helps you answer: *"Is my AI agent secure?"*

```
AI Agent (Claude Code, OpenClaw, Cursor, etc.)
       ↓
OSSASAI asks: Does it have...
  ✓ Authentication? (Who can use it?)
  ✓ Sandboxing? (What can it access?)
  ✓ Logging? (Can you see what it did?)
  ✓ Isolation? (Can users see each other's data?)
       ↓
You check → You know if it's safe to use
```

---

## Why Should I Care?

### The Risk

Without proper security, an AI agent can be tricked into:
- Running malicious commands ("delete all files")
- Leaking your secrets ("show me your .env file")
- Sending spam to your contacts
- Mining cryptocurrency on your computer

### The Solution

OSSASAI provides:

| What | How It Helps |
|------|--------------|
| **Security Controls** | 24 specific things to check |
| **Assurance Levels** | L1 (basic) → L2 (team) → L3 (enterprise) |
| **Verification Steps** | Exact commands to run |
| **Implementation Profiles** | Platform-specific guides |

---

## How To Use This

### Option 1: I Use a Specific AI Agent (Recommended)

Find the **implementation profile** for your platform:

| Platform | Profile | Link |
|----------|---------|------|
| **OpenClaw** | OCSAS | [github.com/gensecaihq/ocsas](https://github.com/gensecaihq/ocsas) |

> **Want to contribute a profile?** See [Creating Profiles](profiles/overview.md) to add support for other AI agents like Claude Code, Cursor, or your own platform.

The profile gives you:
- Exact settings to configure
- Copy-paste config files
- Commands to verify security

### Option 2: I'm Building an AI Agent

Use OSSASAI as your security requirements:

1. **Read the controls** → [controls/](controls/)
2. **Pick your assurance level** → L1, L2, or L3
3. **Implement the required controls** → Each control has verification steps
4. **Create a profile** → Document how your platform meets each control

### Option 3: I'm Auditing an AI Agent

Use OSSASAI as your audit framework:

1. **Review the threat model** → [threat-model/](threat-model/)
2. **Check each applicable control** → [controls/](controls/)
3. **Collect evidence** → [compliance/](compliance/)
4. **Generate report** → [tools/ossasai-report.py](tools/ossasai-report.py)

---

## Quick Start: 5-Minute Security Check

If you're using **OpenClaw**, run:

```bash
# Check your security posture
openclaw security audit --deep

# Auto-fix common issues
openclaw security audit --fix

# Verify it worked
openclaw health
```

For other platforms, check if they have an OSSASAI profile or follow the [generic quickstart](implementation/quickstart.md).

---

## The 24 Security Controls (Overview)

OSSASAI defines 24 controls across 7 domains:

### 1. General Security (GEN)
| Control | What It Checks |
|---------|----------------|
| GEN-01 | Is security enabled by default? |
| GEN-02 | Does it fail safely (deny access on error)? |
| GEN-03 | Does it use least privilege? |
| GEN-04 | Are there multiple security layers? |
| GEN-05 | Is there audit logging? |

### 2. Control Plane (CP)
| Control | What It Checks |
|---------|----------------|
| CP-01 | Is the admin interface hidden by default? |
| CP-02 | Is authentication required? |
| CP-03 | Are proxy headers validated? |
| CP-04 | Are operator and agent identities separate? |

### 3. Identity & Session (ID)
| Control | What It Checks |
|---------|----------------|
| ID-01 | Are new contacts verified before access? |
| ID-02 | Are user sessions isolated from each other? |
| ID-03 | Are group/channel policies enforced? |

### 4. Tool Governance (TB)
| Control | What It Checks |
|---------|----------------|
| TB-01 | Are tools restricted to minimum needed? |
| TB-02 | Do dangerous actions require approval? |
| TB-03 | Is there sandboxing for untrusted code? |
| TB-04 | Is data exfiltration prevented? |

### 5. Local State (LS)
| Control | What It Checks |
|---------|----------------|
| LS-01 | Are secrets encrypted/protected at rest? |
| LS-02 | Are logs redacted of sensitive data? |
| LS-03 | Is memory protected from injection? |
| LS-04 | Can data be deleted on request? |

### 6. Supply Chain (SC)
| Control | What It Checks |
|---------|----------------|
| SC-01 | Are plugins from trusted sources only? |
| SC-02 | Are dependencies pinned and verified? |

### 7. Network Security (NS)
| Control | What It Checks |
|---------|----------------|
| NS-01 | Is TLS enforced? |
| NS-02 | Are certificates validated? |
| NS-03 | Are API endpoints secured? |
| NS-04 | Is network discovery secured? |

---

## Assurance Levels

Pick based on your deployment:

| Level | Name | Who It's For | Security Posture |
|-------|------|--------------|------------------|
| **L1** | Local-First | Solo developers, local testing | Basic protection |
| **L2** | Network-Aware | Teams, shared environments | Multi-user isolation |
| **L3** | High-Assurance | Enterprise, compliance needs | Maximum security |

### What Each Level Requires

```
L1 (Basic)
├── Authentication enabled
├── Default-deny for unknown contacts
├── File permissions correct
└── Logging enabled

L2 (Team) = L1 +
├── Session isolation between users
├── Sandboxing for non-trusted sessions
├── TLS for network connections
└── Plugin verification

L3 (Enterprise) = L2 +
├── All sessions sandboxed
├── Formal verification (optional)
├── Tamper-evident logging
└── Full audit trail
```

---

## Implementation Profiles

OSSASAI is generic. **Profiles** translate it to specific platforms:

```
OSSASAI Control: "ID-01: Verify new contacts"
       ↓
OpenClaw Profile (OCSAS): "Set dmPolicy: 'pairing'"
       ↓
Your Platform Profile: [Document how your platform implements this]
```

### Available Profiles

| Profile | Platform | Repository |
|---------|----------|------------|
| **OCSAS** | OpenClaw | [github.com/gensecaihq/ocsas](https://github.com/gensecaihq/ocsas) |

### Creating a New Profile

Want to create a profile for another AI agent? See [Creating Profiles](profiles/overview.md).

---

## Framework Structure

```
ossasai/
├── spec/                     # What OSSASAI requires
│   ├── overview.md           # Framework overview
│   ├── assurance-levels.md   # L1/L2/L3 definitions
│   └── trust-boundaries.md   # Security boundaries
├── threat-model/             # What attacks look like
│   ├── adversary-classes.md  # Who might attack
│   ├── ai-agent-threats.md   # AI-specific attacks
│   └── attack-vectors.md     # How attacks happen
├── controls/                 # What to check
│   ├── general.md            # GEN-01 to GEN-05
│   ├── control-plane.md      # CP-01 to CP-04
│   ├── identity-session.md   # ID-01 to ID-03
│   └── ...                   # Other domains
├── implementation/           # How to deploy securely
│   ├── quickstart.md         # Fast setup
│   └── l1-deployment.md      # Level-specific guides
├── compliance/               # How to prove security
│   └── evidence-collection.md
└── tools/                    # Automation
    ├── ossasai-audit.sh      # Audit script
    └── ossasai-report.py     # Report generator
```

---

## Standards Alignment

OSSASAI builds on established frameworks:

| Standard | What We Took From It |
|----------|---------------------|
| OWASP ASVS | Control structure, verification approach |
| NIST 800-53 | Risk categorization, control families |
| CIS Controls | Prioritization, implementation groups |
| MITRE ATT&CK | Threat taxonomy, attack patterns |

---

## FAQ

### "Do AI agent developers need to implement OSSASAI?"

No. OSSASAI documents existing security features. If an AI agent already has authentication, sandboxing, and logging, OSSASAI just provides a way to verify and communicate that.

### "Is this only for OpenClaw?"

No. OSSASAI is generic. OpenClaw has a profile (OCSAS), but you can create profiles for any AI agent platform.

### "Who maintains this?"

OSSASAI is community-driven. Contributions welcome — see [Contributing](#contributing).

### "Is this an official standard?"

Not yet. It's a community framework. We align with official standards (NIST, OWASP, CIS) where possible.

---

## Contributing

We welcome:

- **Framework improvements** → Issues and PRs
- **New profiles** → For other AI agent platforms
- **Threat research** → New attack patterns and mitigations
- **Documentation** → Clearer explanations, more examples

---

## License

[Apache License 2.0](LICENSE)

---

**OSSASAI v0.1.0** | Security framework for AI agents
