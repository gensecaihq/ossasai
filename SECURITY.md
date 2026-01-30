# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in the OSSASAI framework, please report it responsibly:

1. **Do not** open a public GitHub issue
2. Email: https://github.com/gensecaihq/ossasai/security/advisories/new
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will respond within 48 hours and work with you to address the issue.

## Scope

This security policy covers:

- OSSASAI specification documents
- Control definitions and requirements
- Reference tooling and scripts
- Implementation guidance

For vulnerabilities in specific implementations (like OCSAS/OpenClaw), please report to the respective project maintainers.

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Security Design Principles

OSSASAI is built on established security principles:

1. **Defense in Depth** - Multiple layers of controls
2. **Least Privilege** - Minimal necessary access
3. **Fail Secure** - Default to deny
4. **Complete Mediation** - Verify every access
5. **Separation of Concerns** - Distinct trust boundaries
