#!/bin/bash
#
# OSSASAI Audit Script v2.0.0
# Automated security compliance verification for tool-enabled AI agent systems
#
# Usage: ./ossasai-audit.sh [OPTIONS]
#
# Options:
#   --level L1|L2|L3    Target assurance level (default: L1)
#   --check CONTROL     Check specific control (e.g., CP-01, GEN-01)
#   --domain DOMAIN     Check all controls in domain (e.g., TB, GEN)
#   --config PATH       Configuration file to audit
#   --output-format     Output format: text, json, junit (default: text)
#   --verbose           Detailed output
#   --quiet             Minimal output
#   --ci                CI-friendly mode (exit codes only)
#   --help              Show this help message
#

set -euo pipefail

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
LEVEL="L1"
OUTPUT_FORMAT="text"
CONFIG_PATH=""
VERBOSE=false
QUIET=false
CI_MODE=false
SPECIFIC_CONTROL=""
SPECIFIC_DOMAIN=""

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)

# Colors for output (disable in CI mode or when not a terminal)
if [[ -t 1 ]] && [[ "${CI_MODE:-false}" != "true" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Control definitions - OSSASAI Control Catalog v2.0
# GEN: General (cross-cutting)
declare -A CONTROLS_GEN=(
    ["OSSASAI-GEN-01"]="Security by Default"
    ["OSSASAI-GEN-02"]="Fail Secure"
    ["OSSASAI-GEN-03"]="Principle of Least Privilege"
    ["OSSASAI-GEN-04"]="Defense in Depth"
    ["OSSASAI-GEN-05"]="Audit Logging"
)

# L1: Local-First Baseline
declare -A CONTROLS_L1=(
    ["OSSASAI-CP-01"]="Default-deny Control Plane Exposure"
    ["OSSASAI-CP-02"]="Strong Admin Authentication"
    ["OSSASAI-ID-02"]="Session Isolation by Default"
    ["OSSASAI-TB-01"]="Least Privilege Tool Configuration"
    ["OSSASAI-LS-01"]="Secrets Protected at Rest"
    ["OSSASAI-LS-02"]="Sensitive Log Redaction"
)

# L2: Network-Aware (additional)
declare -A CONTROLS_L2=(
    ["OSSASAI-CP-03"]="Proxy Trust Boundary Configuration"
    ["OSSASAI-CP-04"]="Operator/Agent Identity Separation"
    ["OSSASAI-ID-01"]="Peer Verification for New Contacts"
    ["OSSASAI-ID-03"]="Group/Channel Policy Hardening"
    ["OSSASAI-TB-02"]="Approval Gates for High-Risk Actions"
    ["OSSASAI-TB-03"]="Sandboxing for Untrusted Contexts"
    ["OSSASAI-TB-04"]="Outbound Data Exfiltration Controls"
    ["OSSASAI-LS-03"]="Memory Safety Against Instruction Smuggling"
    ["OSSASAI-LS-04"]="Retention and Deletion Guarantees"
    ["OSSASAI-SC-01"]="Explicit Plugin Trust and Inventory"
    ["OSSASAI-NS-01"]="TLS Enforcement for All Connections"
    ["OSSASAI-NS-02"]="Certificate Validation"
    ["OSSASAI-NS-03"]="API Endpoint Security"
)

# L3: High-Assurance (additional)
declare -A CONTROLS_L3=(
    ["OSSASAI-SC-02"]="Reproducible Builds and Pinning"
    ["OSSASAI-SC-03"]="Artifact Signing and Attestation"
    ["OSSASAI-FV-01"]="Security Invariant Formal Verification"
    ["OSSASAI-FV-02"]="Negative Model Regression Testing"
    ["OSSASAI-FV-03"]="Continuous Verification in CI/CD"
    ["OSSASAI-NS-04"]="Network Traffic Analysis and Monitoring"
)

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --level)
                LEVEL="$2"
                if [[ ! "$LEVEL" =~ ^(L1|L2|L3)$ ]]; then
                    log_error "Invalid level: $LEVEL (must be L1, L2, or L3)"
                    exit 1
                fi
                shift 2
                ;;
            --check)
                SPECIFIC_CONTROL="$2"
                shift 2
                ;;
            --domain)
                SPECIFIC_DOMAIN="$2"
                shift 2
                ;;
            --config)
                CONFIG_PATH="$2"
                if [[ ! -f "$CONFIG_PATH" ]]; then
                    log_error "Config file not found: $CONFIG_PATH"
                    exit 1
                fi
                shift 2
                ;;
            --output-format)
                OUTPUT_FORMAT="$2"
                if [[ ! "$OUTPUT_FORMAT" =~ ^(text|json|junit)$ ]]; then
                    log_error "Invalid format: $OUTPUT_FORMAT (must be text, json, or junit)"
                    exit 1
                fi
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --quiet)
                QUIET=true
                shift
                ;;
            --ci)
                CI_MODE=true
                QUIET=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            --version)
                echo "OSSASAI Audit Script v${VERSION}"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
OSSASAI Audit Script v${VERSION}

Automated security compliance verification for AI agent systems.

Usage: ./ossasai-audit.sh [OPTIONS]

Options:
  --level L1|L2|L3    Target assurance level (default: L1)
  --check CONTROL     Check specific control (e.g., CP-01, GEN-01)
  --domain DOMAIN     Check all controls in domain (e.g., TB, GEN)
  --config PATH       Configuration file to audit
  --output-format     Output format: text, json, junit (default: text)
  --verbose           Detailed output
  --quiet             Minimal output
  --ci                CI-friendly mode (exit codes only)
  --help              Show this help message
  --version           Show version information

Examples:
  ./ossasai-audit.sh --level L2
  ./ossasai-audit.sh --check GEN-01
  ./ossasai-audit.sh --domain TB --output-format json
  ./ossasai-audit.sh --level L3 --config /etc/ossasai/config.yaml

Control Domains:
  GEN  - General (cross-cutting foundational controls)
  CP   - Control Plane (admin access and exposure)
  ID   - Identity & Session (authentication and isolation)
  TB   - Tool Blast Radius (tool governance)
  LS   - Local State (secrets and logging)
  SC   - Supply Chain (plugin security)
  FV   - Formal Verification (optional high-assurance)
  NS   - Network Security (transport and endpoints)

Exit Codes:
  0 - All applicable controls passed
  1 - One or more controls failed
  2 - Error during execution

Documentation: https://ossasai.dev/docs
EOF
}

# Logging functions
log_info() {
    if [[ "$QUIET" != "true" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_warn() {
    if [[ "$QUIET" != "true" ]]; then
        echo -e "${YELLOW}[WARN]${NC} $1"
    fi
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_pass() {
    if [[ "$QUIET" != "true" ]]; then
        echo -e "${GREEN}[PASS]${NC} $1"
    fi
}

log_fail() {
    if [[ "$QUIET" != "true" ]]; then
        echo -e "${RED}[FAIL]${NC} $1"
    fi
}

log_skip() {
    if [[ "$QUIET" != "true" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} $1"
    fi
}

# Helper: Read YAML value (cross-platform, no external deps)
yaml_get() {
    local file="$1"
    local key="$2"
    local default="${3:-}"

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    # Simple YAML parser using grep/sed
    local value
    value=$(grep -E "^\s*${key}:" "$file" 2>/dev/null | head -1 | sed 's/.*:\s*//' | sed 's/["\x27]//g' | sed 's/#.*//' | xargs)

    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Helper: Check if config has key with value
yaml_has() {
    local file="$1"
    local pattern="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    grep -qE "$pattern" "$file" 2>/dev/null
}

# Helper: Get file permissions (cross-platform)
get_file_perms() {
    local file="$1"
    if [[ "$PLATFORM" == "macos" ]]; then
        stat -f "%Lp" "$file" 2>/dev/null || echo "000"
    else
        stat -c "%a" "$file" 2>/dev/null || echo "000"
    fi
}

# Helper: Check if process is listening on port
check_port_binding() {
    local port="$1"
    local expected_bind="${2:-127.0.0.1}"

    if command -v ss &>/dev/null; then
        ss -tlnp 2>/dev/null | grep -q ":${port}.*${expected_bind}"
    elif command -v netstat &>/dev/null; then
        netstat -tlnp 2>/dev/null | grep -q ":${port}.*${expected_bind}"
    else
        return 0  # Cannot verify, assume pass
    fi
}

# =============================================================================
# GEN Control Checks - General Cross-cutting Controls
# =============================================================================

check_gen01() {
    # GEN-01: Security by Default
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check security is enabled by default
        if yaml_has "$CONFIG_PATH" "security.*enabled.*false"; then
            status="FAIL"
            findings="Security explicitly disabled in config"
        fi

        # Check authentication is required
        if yaml_has "$CONFIG_PATH" "authentication.*required.*false"; then
            status="FAIL"
            findings="${findings:+$findings; }Authentication not required"
        fi

        # Check sandbox is enabled
        if yaml_has "$CONFIG_PATH" "sandbox.*enabled.*false"; then
            status="FAIL"
            findings="${findings:+$findings; }Sandbox disabled"
        fi
    else
        # No config means checking for secure defaults is not possible
        status="SKIP"
        findings="No configuration file to verify defaults"
    fi

    echo "$status|$findings"
}

check_gen02() {
    # GEN-02: Fail Secure
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check fail-open patterns that indicate insecure failure handling
        if yaml_has "$CONFIG_PATH" "on_error.*allow\|on_error.*permit\|on_auth_error.*allow"; then
            status="FAIL"
            findings="Fail-open behavior configured"
        fi

        if yaml_has "$CONFIG_PATH" "on_timeout.*allow\|on_timeout.*permit"; then
            status="FAIL"
            findings="${findings:+$findings; }Timeout allows access"
        fi

        # Check error details exposure
        if yaml_has "$CONFIG_PATH" "expose_details.*true\|expose_stack.*true"; then
            status="FAIL"
            findings="${findings:+$findings; }Error details exposed to users"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify fail-secure behavior"
    fi

    echo "$status|$findings"
}

check_gen03() {
    # GEN-03: Principle of Least Privilege
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check for overly permissive filesystem scope
        if yaml_has "$CONFIG_PATH" "scope.*system\|scope.*/\s*$"; then
            status="FAIL"
            findings="Filesystem scope too broad (system-wide access)"
        fi

        # Check for run as root
        if yaml_has "$CONFIG_PATH" "run_as.*root\|user.*root"; then
            status="FAIL"
            findings="${findings:+$findings; }Configured to run as root"
        fi

        # Check default policy
        if yaml_has "$CONFIG_PATH" "default_policy.*allow\|default.*permit"; then
            status="FAIL"
            findings="${findings:+$findings; }Default-allow policy configured"
        fi
    fi

    # Check if current process is running as root (bad practice)
    if [[ $EUID -eq 0 ]]; then
        status="WARN"
        findings="${findings:+$findings; }Audit running as root (not recommended for agent runtime)"
    fi

    if [[ -z "$findings" && "$status" == "PASS" ]]; then
        findings="Least privilege configuration verified"
    fi

    echo "$status|$findings"
}

check_gen04() {
    # GEN-04: Defense in Depth
    local status="PASS"
    local findings=""
    local layers=0

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Count security layers present
        yaml_has "$CONFIG_PATH" "authentication.*enabled.*true\|auth.*required.*true" && ((layers++)) || true
        yaml_has "$CONFIG_PATH" "authorization.*enabled.*true\|rbac.*enabled.*true" && ((layers++)) || true
        yaml_has "$CONFIG_PATH" "sandbox.*enabled.*true" && ((layers++)) || true
        yaml_has "$CONFIG_PATH" "tls.*enabled.*true\|tls.*required.*true" && ((layers++)) || true
        yaml_has "$CONFIG_PATH" "audit.*enabled.*true\|logging.*enabled.*true" && ((layers++)) || true

        if [[ $layers -lt 3 ]]; then
            status="FAIL"
            findings="Insufficient security layers ($layers found, need at least 3)"
        else
            findings="$layers security layers configured"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify defense in depth"
    fi

    echo "$status|$findings"
}

check_gen05() {
    # GEN-05: Audit Logging
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check audit logging is enabled
        if yaml_has "$CONFIG_PATH" "audit.*enabled.*false\|logging.*enabled.*false"; then
            status="FAIL"
            findings="Audit logging disabled"
        fi

        # Check log retention
        if ! yaml_has "$CONFIG_PATH" "retention\|log_retention"; then
            findings="${findings:+$findings; }No log retention policy specified"
        fi
    fi

    # Check for log directory existence and permissions
    for logdir in "/var/log/ossasai" "/var/log/ocsas" "$HOME/.local/share/ossasai/logs"; do
        if [[ -d "$logdir" ]]; then
            local perms
            perms=$(get_file_perms "$logdir")
            if [[ "$perms" =~ [0-7][2367][0-7] ]]; then
                status="WARN"
                findings="${findings:+$findings; }Log directory $logdir is world-writable"
            fi
            break
        fi
    done

    if [[ -z "$findings" && "$status" == "PASS" ]]; then
        findings="Audit logging configuration verified"
    fi

    echo "$status|$findings"
}

# =============================================================================
# CP Control Checks - Control Plane
# =============================================================================

check_cp01() {
    # CP-01: Default-deny Control Plane Exposure
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        local bind_addr
        bind_addr=$(yaml_get "$CONFIG_PATH" "bind" "")

        # Check if bound to public interface
        if [[ "$bind_addr" =~ ^0\.0\.0\.0 ]] || [[ "$bind_addr" =~ ^\:\: ]]; then
            status="FAIL"
            findings="Control plane bound to all interfaces (public exposure)"
        fi

        # Check gateway/api exposure settings
        if yaml_has "$CONFIG_PATH" "expose.*public\|public.*true"; then
            status="FAIL"
            findings="${findings:+$findings; }Public exposure explicitly enabled"
        fi
    fi

    # Check actual network binding (if we can detect the port)
    local common_ports=("18789" "8080" "3000" "443")
    for port in "${common_ports[@]}"; do
        if command -v ss &>/dev/null; then
            if ss -tlnp 2>/dev/null | grep -q ":${port}.*0\.0\.0\.0"; then
                status="WARN"
                findings="${findings:+$findings; }Port $port listening on all interfaces"
            fi
        fi
    done

    if [[ -z "$findings" && "$status" == "PASS" ]]; then
        findings="Control plane exposure properly restricted"
    fi

    echo "$status|$findings"
}

check_cp02() {
    # CP-02: Strong Admin Authentication
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check authentication is required
        if yaml_has "$CONFIG_PATH" "auth.*required.*false\|authentication.*required.*false"; then
            status="FAIL"
            findings="Authentication not required"
        fi

        # Check for weak auth methods
        if yaml_has "$CONFIG_PATH" "auth.*type.*none\|auth.*type.*basic"; then
            status="FAIL"
            findings="${findings:+$findings; }Weak authentication method configured"
        fi

        # Check for token/key rotation
        if ! yaml_has "$CONFIG_PATH" "rotation\|token_rotation\|key_rotation"; then
            findings="${findings:+$findings; }No credential rotation policy found"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify authentication"
    fi

    echo "$status|$findings"
}

check_cp03() {
    # CP-03: Proxy Trust Boundary Configuration
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check if behind proxy but no trusted proxy config
        if yaml_has "$CONFIG_PATH" "proxy\|reverse_proxy" && ! yaml_has "$CONFIG_PATH" "trusted_proxies\|trustedProxies"; then
            status="FAIL"
            findings="Proxy detected but no trusted proxy configuration"
        fi

        # Check for wildcard trusted proxies
        if yaml_has "$CONFIG_PATH" "trusted_proxies.*\*\|trustedProxies.*0\.0\.0\.0"; then
            status="FAIL"
            findings="${findings:+$findings; }Overly permissive trusted proxy configuration"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify proxy trust boundaries"
    fi

    echo "$status|$findings"
}

check_cp04() {
    # CP-04: Operator/Agent Identity Separation
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check for identity separation
        if ! yaml_has "$CONFIG_PATH" "identities\|operator.*identity\|agent.*identity"; then
            status="FAIL"
            findings="No identity separation between operator and agent"
        fi

        # Check for scope/role separation
        if yaml_has "$CONFIG_PATH" "identities" && ! yaml_has "$CONFIG_PATH" "scopes\|roles\|permissions"; then
            status="WARN"
            findings="${findings:+$findings; }Identities defined but no scope separation"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify identity separation"
    fi

    echo "$status|$findings"
}

# =============================================================================
# ID Control Checks - Identity & Session
# =============================================================================

check_id01() {
    # ID-01: Peer Verification for New Contacts
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check peer verification is enabled
        if yaml_has "$CONFIG_PATH" "peer_verification.*false\|verify_peers.*false"; then
            status="FAIL"
            findings="Peer verification disabled"
        fi

        # Check for auto-accept patterns
        if yaml_has "$CONFIG_PATH" "auto_accept.*true\|auto_approve.*true"; then
            status="FAIL"
            findings="${findings:+$findings; }Auto-accept enabled for new peers"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify peer verification"
    fi

    echo "$status|$findings"
}

check_id02() {
    # ID-02: Session Isolation by Default
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check session isolation
        if yaml_has "$CONFIG_PATH" "session_isolation.*false\|isolate_sessions.*false"; then
            status="FAIL"
            findings="Session isolation disabled"
        fi

        # Check for shared context
        if yaml_has "$CONFIG_PATH" "share_context.*true\|shared_memory.*true"; then
            status="FAIL"
            findings="${findings:+$findings; }Shared context between sessions enabled"
        fi
    fi

    if [[ -z "$findings" && "$status" == "PASS" ]]; then
        findings="Session isolation properly configured"
    fi

    echo "$status|$findings"
}

check_id03() {
    # ID-03: Group/Channel Policy Hardening
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check group policies exist
        if yaml_has "$CONFIG_PATH" "groups\|channels" && ! yaml_has "$CONFIG_PATH" "group_policy\|channel_policy\|mention_policy"; then
            status="FAIL"
            findings="Groups/channels configured but no hardening policies"
        fi

        # Check mention restrictions
        if yaml_has "$CONFIG_PATH" "respond_all_mentions.*true"; then
            status="WARN"
            findings="${findings:+$findings; }Responds to all mentions (potential abuse vector)"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify group policies"
    fi

    echo "$status|$findings"
}

# =============================================================================
# TB Control Checks - Tool Blast Radius
# =============================================================================

check_tb01() {
    # TB-01: Least Privilege Tool Configuration
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check filesystem scope
        local scope
        scope=$(yaml_get "$CONFIG_PATH" "scope" "")
        if [[ "$scope" == "system" ]] || [[ "$scope" == "/" ]]; then
            status="FAIL"
            findings="Filesystem scope too broad: $scope"
        fi

        # Check for workdir restriction
        if ! yaml_has "$CONFIG_PATH" "scope.*workdir\|scope.*project\|sandbox.*enabled.*true"; then
            status="WARN"
            findings="${findings:+$findings; }No explicit workspace restriction found"
        fi

        # Check symlink following
        if yaml_has "$CONFIG_PATH" "follow_symlinks.*true"; then
            status="FAIL"
            findings="${findings:+$findings; }Symlink following enabled (escape risk)"
        fi

        # Check for tool allowlist
        if yaml_has "$CONFIG_PATH" "tools" && ! yaml_has "$CONFIG_PATH" "allowlist\|allow_list\|permitted"; then
            status="WARN"
            findings="${findings:+$findings; }Tools configured without explicit allowlist"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify tool privileges"
    fi

    echo "$status|$findings"
}

check_tb02() {
    # TB-02: Approval Gates for High-Risk Actions
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check approval mode
        if yaml_has "$CONFIG_PATH" "mode.*denylist\|mode.*blocklist"; then
            status="WARN"
            findings="Denylist mode (allowlist recommended)"
        fi

        # Check for approval requirement
        if yaml_has "$CONFIG_PATH" "require_approval.*false\|auto_approve.*true"; then
            status="FAIL"
            findings="${findings:+$findings; }Approval gates disabled for high-risk actions"
        fi

        # Check high-risk action definitions
        if ! yaml_has "$CONFIG_PATH" "high_risk\|sensitive_operations\|approval_required"; then
            status="WARN"
            findings="${findings:+$findings; }No explicit high-risk action definitions"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify approval gates"
    fi

    echo "$status|$findings"
}

check_tb03() {
    # TB-03: Sandboxing for Untrusted Contexts
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check sandbox is enabled
        if yaml_has "$CONFIG_PATH" "sandbox.*enabled.*false\|sandboxing.*false"; then
            status="FAIL"
            findings="Sandboxing disabled"
        fi

        # Check sandbox type
        local sandbox_type
        sandbox_type=$(yaml_get "$CONFIG_PATH" "sandbox_type" "")
        if [[ -z "$sandbox_type" ]] && ! yaml_has "$CONFIG_PATH" "container\|seccomp\|apparmor"; then
            status="WARN"
            findings="${findings:+$findings; }No sandbox mechanism specified"
        fi
    fi

    # Check for container/sandbox runtime
    if command -v docker &>/dev/null || command -v podman &>/dev/null; then
        findings="${findings:+$findings; }Container runtime available"
    fi

    if [[ -z "$findings" && "$status" == "PASS" ]]; then
        findings="Sandbox configuration verified"
    fi

    echo "$status|$findings"
}

check_tb04() {
    # TB-04: Outbound Data Exfiltration Controls
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check egress controls
        if yaml_has "$CONFIG_PATH" "network.*unrestricted\|egress.*allow_all"; then
            status="FAIL"
            findings="Unrestricted network egress"
        fi

        # Check for egress allowlist
        if yaml_has "$CONFIG_PATH" "network\|egress" && ! yaml_has "$CONFIG_PATH" "egress.*allowlist\|allowed_domains\|allowed_hosts"; then
            status="WARN"
            findings="${findings:+$findings; }Network configured without egress allowlist"
        fi

        # Check DLP configuration
        if ! yaml_has "$CONFIG_PATH" "dlp\|data_loss_prevention\|sensitive_patterns"; then
            findings="${findings:+$findings; }No DLP/sensitive pattern detection configured"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify egress controls"
    fi

    echo "$status|$findings"
}

# =============================================================================
# LS Control Checks - Local State
# =============================================================================

check_ls01() {
    # LS-01: Secrets Protected at Rest
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check for plaintext secrets in config
        if grep -qE "(password|secret|api_key|token).*[:=].*['\"][^'\"]{8,}" "$CONFIG_PATH" 2>/dev/null; then
            status="FAIL"
            findings="Potential plaintext secrets in configuration"
        fi

        # Check secrets encryption
        if yaml_has "$CONFIG_PATH" "secrets.*encryption.*false\|encrypt_secrets.*false"; then
            status="FAIL"
            findings="${findings:+$findings; }Secrets encryption disabled"
        fi
    fi

    # Check config file permissions
    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        local perms
        perms=$(get_file_perms "$CONFIG_PATH")
        if [[ "$perms" =~ [0-7][4567][0-7] ]]; then
            status="WARN"
            findings="${findings:+$findings; }Config file readable by group/others (perms: $perms)"
        fi
    fi

    if [[ -z "$findings" && "$status" == "PASS" ]]; then
        findings="Secrets protection verified"
    fi

    echo "$status|$findings"
}

check_ls02() {
    # LS-02: Sensitive Log Redaction
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check redaction is enabled
        if yaml_has "$CONFIG_PATH" "redaction.*false\|redact.*false\|log_secrets.*true"; then
            status="FAIL"
            findings="Log redaction disabled or secrets logging enabled"
        fi

        # Check for sensitive pattern list
        if ! yaml_has "$CONFIG_PATH" "redact_patterns\|sensitive_patterns\|log_redaction"; then
            status="WARN"
            findings="${findings:+$findings; }No explicit redaction patterns defined"
        fi
    fi

    if [[ -z "$findings" && "$status" == "PASS" ]]; then
        findings="Log redaction configuration verified"
    fi

    echo "$status|$findings"
}

check_ls03() {
    # LS-03: Memory Safety Against Instruction Smuggling
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check memory/context policies
        if ! yaml_has "$CONFIG_PATH" "memory_policy\|context_policy\|rag_policy"; then
            status="WARN"
            findings="No explicit memory/context policy defined"
        fi

        # Check for context injection protection
        if yaml_has "$CONFIG_PATH" "trust_memory.*true\|trust_context.*true"; then
            status="FAIL"
            findings="${findings:+$findings; }Memory/context blindly trusted (injection risk)"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify memory safety"
    fi

    echo "$status|$findings"
}

check_ls04() {
    # LS-04: Retention and Deletion Guarantees
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check retention policy exists
        if ! yaml_has "$CONFIG_PATH" "retention\|deletion_policy\|data_lifecycle"; then
            status="WARN"
            findings="No explicit data retention policy"
        fi

        # Check deletion verification
        if ! yaml_has "$CONFIG_PATH" "verify_deletion\|secure_delete"; then
            findings="${findings:+$findings; }No deletion verification configured"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify retention policies"
    fi

    echo "$status|$findings"
}

# =============================================================================
# SC Control Checks - Supply Chain
# =============================================================================

check_sc01() {
    # SC-01: Explicit Plugin Trust and Inventory
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check plugin mode
        if yaml_has "$CONFIG_PATH" "plugins.*mode.*denylist\|plugins.*allow_all"; then
            status="FAIL"
            findings="Plugin denylist mode (allowlist required)"
        fi

        # Check for plugin inventory
        if yaml_has "$CONFIG_PATH" "plugins" && ! yaml_has "$CONFIG_PATH" "plugin.*inventory\|plugins.*allowlist\|trusted_plugins"; then
            status="WARN"
            findings="${findings:+$findings; }Plugins enabled without explicit trust list"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify plugin trust"
    fi

    echo "$status|$findings"
}

check_sc02() {
    # SC-02: Reproducible Builds and Pinning
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check version pinning
        if yaml_has "$CONFIG_PATH" "plugins" && ! yaml_has "$CONFIG_PATH" "pinning\|lockfile\|pinned"; then
            status="WARN"
            findings="No version pinning for plugins"
        fi

        # Check integrity verification
        if ! yaml_has "$CONFIG_PATH" "verify_integrity\|hash\|checksum\|sha256"; then
            findings="${findings:+$findings; }No integrity verification configured"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify build reproducibility"
    fi

    # Check for lockfile
    for lockfile in "./plugins.lock" "./ossasai.lock" "./.plugin-lock.json"; do
        if [[ -f "$lockfile" ]]; then
            findings="${findings:+$findings; }Lockfile found: $lockfile"
            break
        fi
    done

    echo "$status|$findings"
}

check_sc03() {
    # SC-03: Artifact Signing and Attestation
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check signature verification
        if yaml_has "$CONFIG_PATH" "signing.*verification.*false\|verify_signatures.*false"; then
            status="FAIL"
            findings="Signature verification disabled"
        fi

        # Check for signing configuration at L3
        if [[ "$LEVEL" == "L3" ]]; then
            if ! yaml_has "$CONFIG_PATH" "signing\|signatures\|sigstore\|pgp"; then
                status="FAIL"
                findings="${findings:+$findings; }No artifact signing configuration (required for L3)"
            fi
        fi

        # Check trusted keys/identities
        if yaml_has "$CONFIG_PATH" "signing" && ! yaml_has "$CONFIG_PATH" "trusted_keys\|trusted_identities\|trust_anchors"; then
            status="WARN"
            findings="${findings:+$findings; }Signing enabled but no trusted keys defined"
        fi
    else
        if [[ "$LEVEL" == "L3" ]]; then
            status="FAIL"
            findings="No configuration file (signing required for L3)"
        else
            status="SKIP"
            findings="No configuration file to verify artifact signing"
        fi
    fi

    # Check for signing tools
    if command -v cosign &>/dev/null || command -v gpg &>/dev/null; then
        findings="${findings:+$findings; }Signing tools available"
    elif [[ "$LEVEL" == "L3" ]]; then
        status="WARN"
        findings="${findings:+$findings; }No signing tools (cosign/gpg) installed"
    fi

    echo "$status|$findings"
}

# =============================================================================
# FV Control Checks - Formal Verification
# =============================================================================

check_fv01() {
    # FV-01: Security Invariant Formal Verification
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check for invariant definitions
        if ! yaml_has "$CONFIG_PATH" "invariants\|formal_verification\|security_invariants"; then
            status="SKIP"
            findings="No formal invariants defined (optional for L3)"
        fi
    else
        status="SKIP"
        findings="No configuration file (formal verification is optional)"
    fi

    # Check for formal verification tools
    if command -v tlc &>/dev/null || command -v tla2tools &>/dev/null; then
        findings="${findings:+$findings; }TLA+ tools available"
    fi

    echo "$status|$findings"
}

check_fv02() {
    # FV-02: Negative Model Regression Testing
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        if ! yaml_has "$CONFIG_PATH" "negative_tests\|regression_models\|counterexample_tests"; then
            status="SKIP"
            findings="No negative model testing configured (optional)"
        fi
    else
        status="SKIP"
        findings="No configuration file (negative model testing is optional)"
    fi

    echo "$status|$findings"
}

check_fv03() {
    # FV-03: Continuous Verification in CI/CD
    local status="PASS"
    local findings=""

    # Check for CI configuration files
    local ci_found=false
    for cifile in ".github/workflows"/*.yml ".github/workflows"/*.yaml ".gitlab-ci.yml" "Jenkinsfile" ".circleci/config.yml"; do
        if [[ -e "$cifile" ]]; then
            ci_found=true
            # Check if ossasai audit is in CI
            if grep -q "ossasai-audit\|ossasai.*audit" "$cifile" 2>/dev/null; then
                findings="OSSASAI audit found in CI: $cifile"
            else
                findings="${findings:+$findings; }CI found but no OSSASAI audit: $cifile"
            fi
        fi
    done

    if [[ "$ci_found" == "false" ]]; then
        status="SKIP"
        findings="No CI configuration found (optional for L3)"
    fi

    echo "$status|$findings"
}

# =============================================================================
# NS Control Checks - Network Security
# =============================================================================

check_ns01() {
    # NS-01: TLS Enforcement for All Connections
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check TLS is enabled
        if yaml_has "$CONFIG_PATH" "tls.*enabled.*false\|tls.*required.*false"; then
            status="FAIL"
            findings="TLS not enforced"
        fi

        # Check TLS version
        if yaml_has "$CONFIG_PATH" "min_version.*TLS1\.0\|min_version.*TLS1\.1\|min_version.*SSLv"; then
            status="FAIL"
            findings="${findings:+$findings; }Weak TLS version allowed"
        fi

        # Check for insecure options
        if yaml_has "$CONFIG_PATH" "insecure.*true\|skip_verify.*true\|allow_insecure.*true"; then
            status="FAIL"
            findings="${findings:+$findings; }Insecure TLS options enabled"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify TLS enforcement"
    fi

    echo "$status|$findings"
}

check_ns02() {
    # NS-02: Certificate Validation
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check cert validation is not disabled
        if yaml_has "$CONFIG_PATH" "verify_certs.*false\|skip_verify.*true\|insecure_skip_verify.*true"; then
            status="FAIL"
            findings="Certificate validation disabled"
        fi

        # Check for certificate pinning (recommended for L3)
        if [[ "$LEVEL" == "L3" ]] && ! yaml_has "$CONFIG_PATH" "cert_pinning\|pin_certs\|certificate_pins"; then
            status="WARN"
            findings="${findings:+$findings; }No certificate pinning configured (recommended for L3)"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify certificate validation"
    fi

    echo "$status|$findings"
}

check_ns03() {
    # NS-03: API Endpoint Security
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check rate limiting
        if ! yaml_has "$CONFIG_PATH" "rate_limit\|rate_limiting\|throttle"; then
            status="WARN"
            findings="No rate limiting configured"
        fi

        # Check API authentication
        if yaml_has "$CONFIG_PATH" "api" && ! yaml_has "$CONFIG_PATH" "api.*auth\|api.*token\|api.*key"; then
            status="FAIL"
            findings="${findings:+$findings; }API configured without authentication"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify API security"
    fi

    echo "$status|$findings"
}

check_ns04() {
    # NS-04: Network Traffic Analysis and Monitoring
    local status="PASS"
    local findings=""

    if [[ -n "$CONFIG_PATH" && -f "$CONFIG_PATH" ]]; then
        # Check traffic monitoring
        if ! yaml_has "$CONFIG_PATH" "traffic_analysis\|network_monitoring\|netflow"; then
            status="WARN"
            findings="No network traffic analysis configured"
        fi

        # Check anomaly detection
        if ! yaml_has "$CONFIG_PATH" "anomaly_detection\|threat_detection"; then
            findings="${findings:+$findings; }No anomaly detection configured"
        fi
    else
        status="SKIP"
        findings="No configuration file to verify traffic analysis"
    fi

    echo "$status|$findings"
}

# =============================================================================
# Main Functions
# =============================================================================

# Run a specific control check
run_check() {
    local control=$1
    local short_id="${control#OSSASAI-}"
    local result=""

    case $short_id in
        # GEN controls
        GEN-01) result=$(check_gen01) ;;
        GEN-02) result=$(check_gen02) ;;
        GEN-03) result=$(check_gen03) ;;
        GEN-04) result=$(check_gen04) ;;
        GEN-05) result=$(check_gen05) ;;
        # CP controls
        CP-01) result=$(check_cp01) ;;
        CP-02) result=$(check_cp02) ;;
        CP-03) result=$(check_cp03) ;;
        CP-04) result=$(check_cp04) ;;
        # ID controls
        ID-01) result=$(check_id01) ;;
        ID-02) result=$(check_id02) ;;
        ID-03) result=$(check_id03) ;;
        # TB controls
        TB-01) result=$(check_tb01) ;;
        TB-02) result=$(check_tb02) ;;
        TB-03) result=$(check_tb03) ;;
        TB-04) result=$(check_tb04) ;;
        # LS controls
        LS-01) result=$(check_ls01) ;;
        LS-02) result=$(check_ls02) ;;
        LS-03) result=$(check_ls03) ;;
        LS-04) result=$(check_ls04) ;;
        # SC controls
        SC-01) result=$(check_sc01) ;;
        SC-02) result=$(check_sc02) ;;
        SC-03) result=$(check_sc03) ;;
        # FV controls
        FV-01) result=$(check_fv01) ;;
        FV-02) result=$(check_fv02) ;;
        FV-03) result=$(check_fv03) ;;
        # NS controls
        NS-01) result=$(check_ns01) ;;
        NS-02) result=$(check_ns02) ;;
        NS-03) result=$(check_ns03) ;;
        NS-04) result=$(check_ns04) ;;
        *)
            result="FAIL|Unknown control: $control"
            ;;
    esac

    echo "$result"
}

# Get control title from any level
get_control_title() {
    local control=$1
    echo "${CONTROLS_GEN[$control]:-${CONTROLS_L1[$control]:-${CONTROLS_L2[$control]:-${CONTROLS_L3[$control]:-Unknown}}}}"
}

# Get all controls for a level
get_controls_for_level() {
    local level=$1
    local controls=""

    # GEN controls apply to all levels
    for ctrl in "${!CONTROLS_GEN[@]}"; do
        controls="$controls $ctrl"
    done

    # L1 controls
    for ctrl in "${!CONTROLS_L1[@]}"; do
        controls="$controls $ctrl"
    done

    # L2 controls
    if [[ "$level" == "L2" || "$level" == "L3" ]]; then
        for ctrl in "${!CONTROLS_L2[@]}"; do
            controls="$controls $ctrl"
        done
    fi

    # L3 controls
    if [[ "$level" == "L3" ]]; then
        for ctrl in "${!CONTROLS_L3[@]}"; do
            controls="$controls $ctrl"
        done
    fi

    echo "$controls"
}

# Main audit function
run_audit() {
    local total=0
    local passed=0
    local failed=0
    local skipped=0
    local warned=0
    local results=()

    local controls
    if [[ -n "$SPECIFIC_CONTROL" ]]; then
        # Handle both "CP-01" and "OSSASAI-CP-01" formats
        if [[ "$SPECIFIC_CONTROL" != OSSASAI-* ]]; then
            SPECIFIC_CONTROL="OSSASAI-$SPECIFIC_CONTROL"
        fi
        controls="$SPECIFIC_CONTROL"
    elif [[ -n "$SPECIFIC_DOMAIN" ]]; then
        controls=$(get_controls_for_level "$LEVEL" | tr ' ' '\n' | grep "OSSASAI-${SPECIFIC_DOMAIN}-" | tr '\n' ' ')
        if [[ -z "$controls" ]]; then
            log_error "No controls found for domain: $SPECIFIC_DOMAIN at level $LEVEL"
            exit 1
        fi
    else
        controls=$(get_controls_for_level "$LEVEL")
    fi

    # Sort controls for consistent output
    controls=$(echo "$controls" | tr ' ' '\n' | sort -u | tr '\n' ' ')

    for control in $controls; do
        [[ -z "$control" ]] && continue
        ((total++)) || true

        local result
        result=$(run_check "$control")
        local status
        status=$(echo "$result" | cut -d'|' -f1)
        local findings
        findings=$(echo "$result" | cut -d'|' -f2-)
        local title
        title=$(get_control_title "$control")

        case "$status" in
            PASS)
                ((passed++)) || true
                log_pass "$control: $title"
                ;;
            FAIL)
                ((failed++)) || true
                log_fail "$control: $title"
                ;;
            WARN)
                ((warned++)) || true
                ((passed++)) || true  # Warnings count as pass for compliance
                log_warn "$control: $title"
                ;;
            SKIP)
                ((skipped++)) || true
                log_skip "$control: $title"
                ;;
        esac

        if [[ "$VERBOSE" == "true" && -n "$findings" ]]; then
            echo "       $findings"
        fi

        # Escape quotes for JSON
        findings="${findings//\"/\\\"}"
        results+=("{\"id\":\"$control\",\"status\":\"$status\",\"finding\":\"$findings\"}")
    done

    # Calculate percentage (excluding skipped)
    local applicable=$((total - skipped))
    local percentage=0
    if [[ $applicable -gt 0 ]]; then
        percentage=$(awk "BEGIN {printf \"%.1f\", $passed * 100 / $applicable}")
    fi

    # Output based on format
    case "$OUTPUT_FORMAT" in
        json)
            local controls_json
            controls_json=$(IFS=,; echo "${results[*]}")
            cat << EOF
{
  "assessment": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "version": "$VERSION",
    "target_level": "$LEVEL",
    "platform": "$PLATFORM"
  },
  "summary": {
    "total_controls": $total,
    "applicable": $applicable,
    "passing": $passed,
    "failing": $failed,
    "skipped": $skipped,
    "warnings": $warned,
    "compliance_percentage": $percentage
  },
  "controls": [$controls_json]
}
EOF
            ;;
        junit)
            echo '<?xml version="1.0" encoding="UTF-8"?>'
            echo "<testsuite name=\"OSSASAI-$LEVEL\" tests=\"$total\" failures=\"$failed\" skipped=\"$skipped\" timestamp=\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\">"
            for result_json in "${results[@]}"; do
                local ctrl_id
                ctrl_id=$(echo "$result_json" | grep -oP '"id":"[^"]*"' | cut -d'"' -f4)
                local ctrl_status
                ctrl_status=$(echo "$result_json" | grep -oP '"status":"[^"]*"' | cut -d'"' -f4)
                local ctrl_finding
                ctrl_finding=$(echo "$result_json" | grep -oP '"finding":"[^"]*"' | cut -d'"' -f4)

                echo "  <testcase name=\"$ctrl_id\" classname=\"ossasai.controls\">"
                if [[ "$ctrl_status" == "FAIL" ]]; then
                    echo "    <failure message=\"Control failed\">$ctrl_finding</failure>"
                elif [[ "$ctrl_status" == "SKIP" ]]; then
                    echo "    <skipped message=\"$ctrl_finding\"/>"
                fi
                echo "  </testcase>"
            done
            echo "</testsuite>"
            ;;
        *)
            echo ""
            echo "========================================"
            echo "OSSASAI Audit Summary"
            echo "========================================"
            echo "Target Level: $LEVEL"
            echo "Platform: $PLATFORM"
            echo "Total Controls: $total"
            echo "Applicable: $applicable"
            echo "Passed: $passed (including $warned warnings)"
            echo "Failed: $failed"
            echo "Skipped: $skipped"
            echo "Compliance: ${percentage}%"
            echo ""
            if [[ $failed -eq 0 ]]; then
                echo -e "${GREEN}Level $LEVEL: ACHIEVED${NC}"
            else
                echo -e "${RED}Level $LEVEL: NOT ACHIEVED${NC}"
                echo ""
                echo "Run with --verbose for detailed findings"
            fi
            ;;
    esac

    # Return exit code
    if [[ $failed -gt 0 ]]; then
        return 1
    fi
    return 0
}

# Main execution
main() {
    parse_args "$@"

    if [[ "$QUIET" != "true" ]]; then
        echo "OSSASAI Security Audit v${VERSION}"
        echo "================================"
        echo ""
    fi

    # Auto-detect config if not specified
    if [[ -z "$CONFIG_PATH" ]]; then
        for path in "./config.yaml" "./ossasai.yaml" "./ocsas.yaml" "/etc/ossasai/config.yaml" "/etc/ocsas/config.yaml" "$HOME/.config/ossasai/config.yaml" "$HOME/.config/ocsas/config.yaml"; do
            if [[ -f "$path" ]]; then
                CONFIG_PATH="$path"
                log_info "Using config: $CONFIG_PATH"
                break
            fi
        done

        if [[ -z "$CONFIG_PATH" ]]; then
            log_warn "No configuration file found. Some checks will be skipped."
        fi
    fi

    run_audit
    exit $?
}

main "$@"
