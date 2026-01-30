---
title: 'Profile Registry'
description: 'Central registry of OSSASAI implementation profiles and compatibility tracking'
---

## Overview

The OSSASAI Profile Registry serves as the authoritative source for all implementation profiles. It tracks profile versions, compatibility with OSSASAI framework versions, and provides notifications when framework changes require profile updates.

> **Note:** Profile maintainers should register their profiles here to receive notifications about framework changes that may affect their implementations.

## Registry Endpoint

### Base URL

```
https://ossasai.dev/api/v1/profiles
```

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/profiles` | GET | List all registered profiles |
| `/profiles/{id}` | GET | Get specific profile details |
| `/profiles/{id}/compatibility` | GET | Check compatibility with OSSASAI versions |
| `/profiles/register` | POST | Register a new profile |
| `/profiles/{id}/webhook` | POST | Register webhook for change notifications |
| `/framework/changes` | GET | List framework changes affecting profiles |
| `/framework/controls` | GET | Get current control catalog |

## Registered Profiles


  ### [OCSAS](/profiles/openclaw)

**OpenClaw Security Assurance Standard**

    | Attribute | Value |
    |-----------|-------|
    | Profile ID | `OSSASAI-PROFILE-OPENCLAW-OCSAS` |
    | Current Version | 1.0.0 |
    | OSSASAI Compatibility | 0.1.0 - 0.2.x |
    | Status | Official |
    | Maintainer | OSSASAI Project |


## Compatibility Matrix

### Current Framework Version: 0.2.0

| Profile | Profile Version | Compatible | Notes |
|---------|-----------------|:----------:|-------|
| OCSAS (OpenClaw) | 1.0.0 | Yes | Full compatibility |

### Framework Change Impact

When OSSASAI framework changes, profiles may need updates:

| Change Type | Profile Impact | Action Required |
|-------------|----------------|-----------------|
| New control added | Profile should map new control | Update recommended |
| Control requirement elevated (SHOULD→MUST) | Profile must update mapping | Update required |
| Control deprecated | Profile should remove mapping | Update recommended |
| Verification procedure changed | Profile should update tooling | Update recommended |
| Breaking schema change | Profile must update | Update required |

## Profile Registration

### Registration Schema

```json
{
  "profile": {
    "id": "OSSASAI-PROFILE-PLATFORM-NAME",
    "name": "Human Readable Name",
    "platform": "platform-identifier",
    "version": "1.0.0",
    "ossasai_versions": ["0.1.0", "0.2.0"],
    "status": "community",
    "repository": "https://github.com/org/profile-repo",
    "documentation": "https://docs.example.com/ossasai"
  },
  "maintainer": {
    "name": "Maintainer Name",
    "email": "maintainer@example.com",
    "organization": "Organization Name"
  },
  "webhook": {
    "url": "https://example.com/webhooks/ossasai",
    "events": ["control_added", "control_changed", "breaking_change"]
  }
}
```

### Registration Process


  1. **Prepare Profile**

   Ensure your profile meets all requirements:
       - Maps all 30 OSSASAI controls
       - Includes verification commands
       - Has conformance recipes for L1/L2/L3

  2. **Validate Profile**

   ```bash
       # Validate against profile schema
       ossasai-audit.sh --validate-profile your-profile.yaml
       ```

  3. **Submit Registration**

   Option A: API Registration
       ```bash
       curl -X POST https://ossasai.dev/api/v1/profiles/register \
         -H "Content-Type: application/json" \
         -d @profile-registration.json
       ```
   
       Option B: Pull Request
       - Fork the OSSASAI repository
       - Add your profile to `/profiles/`
       - Update `registry.md` with your profile
       - Submit pull request

  4. **Configure Webhooks**

   Register webhooks to receive framework change notifications:
       ```bash
       curl -X POST https://ossasai.dev/api/v1/profiles/{id}/webhook \
         -H "Content-Type: application/json" \
         -d '{"url": "https://your-domain.com/webhook", "events": ["all"]}'
       ```


## Change Notifications

### Webhook Events

Profiles can subscribe to the following events:

| Event | Trigger | Payload |
|-------|---------|---------|
| `control_added` | New control added to catalog | Control definition |
| `control_changed` | Existing control modified | Changed fields |
| `control_deprecated` | Control marked deprecated | Deprecation notice |
| `requirement_elevated` | SHOULD→MUST change | Control ID, new level |
| `schema_changed` | Profile schema updated | Schema diff |
| `breaking_change` | Major version change | Migration guide |
| `version_released` | New OSSASAI version | Release notes |

### Webhook Payload Format

```json
{
  "event": "control_added",
  "timestamp": "2026-01-30T12:00:00Z",
  "ossasai_version": "0.2.0",
  "data": {
    "control_id": "OSSASAI-GEN-01",
    "title": "Security by Default",
    "requirement_level": "MUST",
    "assurance_levels": ["L1", "L2", "L3"],
    "action_required": "update_recommended",
    "deadline": null
  },
  "migration": {
    "guide_url": "https://ossasai.dev/migration/0.2.0",
    "breaking": false
  }
}
```

### Email Notifications

Profile maintainers also receive email notifications for:
- Breaking changes requiring immediate action
- Quarterly compatibility reports
- Security advisories affecting profiles

## Compatibility Checking

### API Check

```bash
# Check profile compatibility with current framework
curl https://ossasai.dev/api/v1/profiles/OSSASAI-PROFILE-OPENCLAW-OCSAS/compatibility

# Response
{
  "profile_id": "OSSASAI-PROFILE-OPENCLAW-OCSAS",
  "profile_version": "1.0.0",
  "ossasai_version": "0.2.0",
  "compatible": true,
  "coverage": {
    "total_controls": 30,
    "mapped_controls": 30,
    "coverage_percentage": 100
  },
  "issues": [],
  "recommendations": [
    {
      "type": "info",
      "message": "Consider adding platform extensions for MCP server security"
    }
  ]
}
```

### CLI Check

```bash
# Check local profile against registry
ossasai-audit.sh --check-profile-compatibility ./my-profile.yaml

# Output
Profile: OSSASAI-PROFILE-MYPLATFORM-SECURITY-1.0.0
OSSASAI Version: 0.2.0
Status: COMPATIBLE

Control Coverage: 30/30 (100%)
Missing Controls: None
Deprecated Mappings: None

Recommendations:
  - Update verification command for GEN-05 (new format)
```

## Profile Lifecycle

### Status Definitions

| Status | Description |
|--------|-------------|
| `official` | Maintained by OSSASAI project team |
| `verified` | Third-party verified for compliance |
| `community` | Community-contributed, self-attested |
| `deprecated` | No longer maintained, migration recommended |
| `archived` | Historical reference only |

### Deprecation Process

When a profile is deprecated:

1. **Notice Period**: 6 months advance notice
2. **Migration Guide**: Published with recommended alternatives
3. **Registry Update**: Status changed to `deprecated`
4. **Removal**: After 12 months, moved to `archived`

## Framework Version Policy

### Semantic Versioning

OSSASAI follows semantic versioning for framework releases:

| Version Component | Change Type | Profile Impact |
|-------------------|-------------|----------------|
| MAJOR (X.0.0) | Breaking changes | Update required within 6 months |
| MINOR (0.X.0) | New controls/features | Update recommended within 3 months |
| PATCH (0.0.X) | Bug fixes/clarifications | No profile changes needed |

### Compatibility Windows

| OSSASAI Version | Support Window | Profile Compatibility |
|-----------------|----------------|----------------------|
| 0.2.x (current) | Active | All 1.x profiles |
| 0.1.x | Maintenance | Legacy profiles with adapter |
| 1.0.x (future) | Planned | New profile schema required |

## API Reference

### List Profiles

```http
GET /api/v1/profiles
```

**Query Parameters:**
- `status` - Filter by status (official, verified, community)
- `platform` - Filter by platform
- `compatible_with` - Filter by OSSASAI version compatibility

**Response:**
```json
{
  "profiles": [
    {
      "id": "OSSASAI-PROFILE-OPENCLAW-OCSAS",
      "name": "OCSAS - OpenClaw Security Assurance Standard",
      "version": "1.0.0",
      "status": "official",
      "compatible_versions": ["0.1.0", "0.2.0"]
    }
  ],
  "total": 1,
  "page": 1,
  "per_page": 20
}
```

### Get Framework Changes

```http
GET /api/v1/framework/changes?since=0.1.0
```

**Response:**
```json
{
  "from_version": "0.1.0",
  "to_version": "0.2.0",
  "changes": [
    {
      "type": "control_added",
      "control_id": "OSSASAI-GEN-01",
      "title": "Security by Default",
      "impact": "Profiles should add mapping for this control"
    },
    {
      "type": "control_added",
      "control_id": "OSSASAI-GEN-02",
      "title": "Fail Secure",
      "impact": "Profiles should add mapping for this control"
    }
  ],
  "migration_guide": "https://ossasai.dev/migration/0.1.0-to-0.2.0"
}
```

### Get Current Controls

```http
GET /api/v1/framework/controls
```

**Response:**
```json
{
  "ossasai_version": "0.2.0",
  "total_controls": 30,
  "domains": {
    "GEN": {"count": 5, "controls": ["GEN-01", "GEN-02", "GEN-03", "GEN-04", "GEN-05"]},
    "CP": {"count": 4, "controls": ["CP-01", "CP-02", "CP-03", "CP-04"]},
    "ID": {"count": 3, "controls": ["ID-01", "ID-02", "ID-03"]},
    "TB": {"count": 4, "controls": ["TB-01", "TB-02", "TB-03", "TB-04"]},
    "LS": {"count": 4, "controls": ["LS-01", "LS-02", "LS-03", "LS-04"]},
    "SC": {"count": 3, "controls": ["SC-01", "SC-02", "SC-03"]},
    "FV": {"count": 3, "controls": ["FV-01", "FV-02", "FV-03"]},
    "NS": {"count": 4, "controls": ["NS-01", "NS-02", "NS-03", "NS-04"]}
  }
}
```

## Self-Hosted Registry

Organizations can host their own profile registry for internal profiles:

```yaml
# ossasai-registry-config.yaml
registry:
  type: "self-hosted"
  upstream: "https://ossasai.dev/api/v1"  # Sync with official

  sync:
    enabled: true
    interval: "24h"
    sync_controls: true
    sync_official_profiles: true

  profiles:
    - path: "./profiles/internal-platform.yaml"
      status: "internal"

  webhooks:
    outbound:
      - url: "https://internal-ci.example.com/ossasai"
        events: ["all"]
```

## References

- [Profile Overview](/profiles/overview)
- [OCSAS Profile](/profiles/openclaw)
- [Control Catalog](/controls/overview)
- [Framework Specification](/spec/overview)
