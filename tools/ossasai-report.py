#!/usr/bin/env python3
"""
OSSASAI Compliance Report Generator

Generates compliance reports from audit results in various formats.

Usage:
    python ossasai-report.py --assessment audit.json --output report.txt
    python ossasai-report.py --assessment audit.json --format yaml --output statement.yaml
    python ossasai-report.py --assessment audit.json --format junit --output results.xml
    python ossasai-report.py --assessment audit.json --format pdf --output report.pdf
"""

import argparse
import html
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, List

VERSION = "2.0.0"


def load_assessment(path: str) -> Dict[str, Any]:
    """Load assessment results from JSON file."""
    with open(path, 'r') as f:
        return json.load(f)


def escape_xml(text: str) -> str:
    """Escape text for safe XML output."""
    if text is None:
        return ""
    return html.escape(str(text), quote=True)


def escape_yaml(text: str) -> str:
    """Escape text for safe YAML output."""
    if text is None:
        return ""
    # Handle multiline and special characters
    text = str(text)
    if '\n' in text or ':' in text or '#' in text or '"' in text:
        # Use quoted string
        return '"' + text.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n') + '"'
    return text


def generate_text_report(assessment: Dict[str, Any], evidence_path: Optional[str] = None) -> str:
    """Generate text-format compliance report."""
    summary = assessment.get('summary', {})
    controls = assessment.get('controls', [])
    assessment_info = assessment.get('assessment', {})

    report = []
    report.append("=" * 60)
    report.append("OSSASAI COMPLIANCE REPORT")
    report.append("=" * 60)
    report.append("")
    report.append(f"Generated: {datetime.utcnow().isoformat()}Z")
    report.append(f"Target Level: {assessment_info.get('target_level', 'Unknown')}")
    report.append(f"Platform: {assessment_info.get('platform', 'Unknown')}")
    report.append(f"Audit Version: {assessment_info.get('version', 'Unknown')}")
    report.append("")
    report.append("-" * 60)
    report.append("EXECUTIVE SUMMARY")
    report.append("-" * 60)
    report.append(f"Total Controls: {summary.get('total_controls', 0)}")
    report.append(f"Applicable: {summary.get('applicable', summary.get('total_controls', 0))}")
    report.append(f"Passing: {summary.get('passing', 0)}")
    report.append(f"Failing: {summary.get('failing', 0)}")
    report.append(f"Skipped: {summary.get('skipped', 0)}")
    report.append(f"Warnings: {summary.get('warnings', 0)}")
    report.append(f"Compliance: {summary.get('compliance_percentage', 0)}%")
    report.append("")

    # Fixed: Default to 0 for failing count, not 1
    failing_count = summary.get('failing', 0)
    status = "ACHIEVED" if failing_count == 0 else "NOT ACHIEVED"
    report.append(f"Status: {status}")
    report.append("")

    report.append("-" * 60)
    report.append("CONTROL RESULTS")
    report.append("-" * 60)

    # Group controls by domain
    domains: Dict[str, List[Dict[str, Any]]] = {}
    for control in controls:
        ctrl_id = control.get('id', 'Unknown')
        # Extract domain from control ID (e.g., OSSASAI-CP-01 -> CP)
        parts = ctrl_id.split('-')
        domain = parts[1] if len(parts) >= 2 else 'Other'
        if domain not in domains:
            domains[domain] = []
        domains[domain].append(control)

    # Sort domains
    domain_order = ['GEN', 'CP', 'ID', 'TB', 'LS', 'SC', 'FV', 'NS']
    sorted_domains = sorted(domains.keys(), key=lambda d: domain_order.index(d) if d in domain_order else 99)

    for domain in sorted_domains:
        report.append(f"\n[{domain}]")
        for control in sorted(domains[domain], key=lambda c: c.get('id', '')):
            ctrl_status = control.get('status', 'UNKNOWN')
            if ctrl_status == 'PASS':
                status_symbol = "[PASS]"
            elif ctrl_status == 'WARN':
                status_symbol = "[WARN]"
            elif ctrl_status == 'SKIP':
                status_symbol = "[SKIP]"
            else:
                status_symbol = "[FAIL]"

            report.append(f"  {status_symbol} {control.get('id', 'Unknown')}")
            if ctrl_status not in ('PASS', 'SKIP') and control.get('finding'):
                report.append(f"           Finding: {control.get('finding')}")

    report.append("")
    report.append("-" * 60)

    if evidence_path:
        report.append(f"Evidence Directory: {evidence_path}")
        report.append("-" * 60)

    report.append("END OF REPORT")
    report.append("-" * 60)

    return "\n".join(report)


def generate_json_report(assessment: Dict[str, Any], evidence_path: Optional[str] = None) -> str:
    """Generate JSON-format compliance report."""
    summary = assessment.get('summary', {})

    # Fixed: Use 0 as default for failing count
    failing_count = summary.get('failing', 0)

    report = {
        "report_version": VERSION,
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "status": "conformant" if failing_count == 0 else "non_conformant",
        "assessment": assessment.get('assessment', {}),
        "summary": assessment.get('summary', {}),
        "controls": assessment.get('controls', []),
    }

    if evidence_path:
        report["evidence_path"] = evidence_path

    return json.dumps(report, indent=2)


def generate_yaml_statement(assessment: Dict[str, Any]) -> str:
    """Generate YAML compliance statement."""
    summary = assessment.get('summary', {})
    assessment_info = assessment.get('assessment', {})
    target_level = assessment_info.get('target_level', 'L1')

    # Fixed: Use 0 as default for failing count
    failing = summary.get('failing', 0)
    status = "conformant" if failing == 0 else "non_conformant"

    # Escape values for YAML safety
    statement = f"""# OSSASAI Compliance Statement
# Generated: {datetime.utcnow().isoformat()}Z

compliance_statement:
  schema_version: "1.0"

  assessment:
    ossasai_version: "1.0.0"
    assurance_level: {escape_yaml(target_level)}
    date: "{datetime.utcnow().strftime('%Y-%m-%d')}"
    tool_version: "{VERSION}"
    platform: {escape_yaml(assessment_info.get('platform', 'unknown'))}

  results:
    status: "{status}"
    controls:
      total: {summary.get('total_controls', 0)}
      applicable: {summary.get('applicable', summary.get('total_controls', 0))}
      passed: {summary.get('passing', 0)}
      failed: {failing}
      skipped: {summary.get('skipped', 0)}
      warnings: {summary.get('warnings', 0)}
    compliance_percentage: {summary.get('compliance_percentage', 0)}

  validity:
    effective_date: "{datetime.utcnow().strftime('%Y-%m-%d')}"
    expiration_date: "{(datetime.utcnow().replace(year=datetime.utcnow().year + 1)).strftime('%Y-%m-%d')}"
    # Validity period: 12 months from assessment date

  attestation:
    type: "self-assessment"
    # For third-party assessments, update type and add assessor details
"""
    return statement


def generate_junit_report(assessment: Dict[str, Any]) -> str:
    """Generate JUnit XML format for CI integration."""
    controls = assessment.get('controls', [])
    summary = assessment.get('summary', {})
    assessment_info = assessment.get('assessment', {})

    total = summary.get('total_controls', len(controls))
    failing = summary.get('failing', 0)
    skipped = summary.get('skipped', 0)
    target_level = assessment_info.get('target_level', 'L1')

    xml_parts = []
    xml_parts.append('<?xml version="1.0" encoding="UTF-8"?>')

    # Escape all values for XML safety
    xml_parts.append(
        f'<testsuite name="{escape_xml(f"OSSASAI-{target_level}")}" '
        f'tests="{total}" '
        f'failures="{failing}" '
        f'skipped="{skipped}" '
        f'errors="0" '
        f'timestamp="{escape_xml(datetime.utcnow().isoformat())}">'
    )

    for control in controls:
        # Escape all control values
        ctrl_id = escape_xml(control.get('id', 'unknown'))
        status = control.get('status', 'UNKNOWN')
        finding = escape_xml(control.get('finding', ''))

        xml_parts.append(f'  <testcase name="{ctrl_id}" classname="ossasai.controls">')

        if status == 'FAIL':
            xml_parts.append(f'    <failure message="Control failed" type="AssertionError">')
            xml_parts.append(f'      {finding}')
            xml_parts.append(f'    </failure>')
        elif status == 'SKIP':
            xml_parts.append(f'    <skipped message="{finding}"/>')
        elif status == 'WARN':
            xml_parts.append(f'    <system-out>Warning: {finding}</system-out>')
        # PASS status needs no additional elements

        xml_parts.append('  </testcase>')

    xml_parts.append('</testsuite>')

    return "\n".join(xml_parts)


def generate_pdf_report(assessment: Dict[str, Any], output_path: str, evidence_path: Optional[str] = None) -> bool:
    """Generate PDF-format compliance report.

    Returns True if PDF generation succeeded, False otherwise.
    """
    try:
        # Try to import reportlab
        from reportlab.lib import colors
        from reportlab.lib.pagesizes import letter
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
    except ImportError:
        print("Warning: reportlab not installed. Install with: pip install reportlab", file=sys.stderr)
        print("Falling back to text format.", file=sys.stderr)
        return False

    summary = assessment.get('summary', {})
    controls = assessment.get('controls', [])
    assessment_info = assessment.get('assessment', {})

    doc = SimpleDocTemplate(output_path, pagesize=letter)
    styles = getSampleStyleSheet()
    story = []

    # Title
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        spaceAfter=30,
        alignment=1  # Center
    )
    story.append(Paragraph("OSSASAI Compliance Report", title_style))
    story.append(Spacer(1, 12))

    # Assessment info
    story.append(Paragraph(f"<b>Generated:</b> {datetime.utcnow().isoformat()}Z", styles['Normal']))
    story.append(Paragraph(f"<b>Target Level:</b> {assessment_info.get('target_level', 'Unknown')}", styles['Normal']))
    story.append(Paragraph(f"<b>Platform:</b> {assessment_info.get('platform', 'Unknown')}", styles['Normal']))
    story.append(Spacer(1, 20))

    # Summary table
    story.append(Paragraph("Executive Summary", styles['Heading2']))
    failing_count = summary.get('failing', 0)
    status = "ACHIEVED" if failing_count == 0 else "NOT ACHIEVED"

    summary_data = [
        ['Metric', 'Value'],
        ['Total Controls', str(summary.get('total_controls', 0))],
        ['Passing', str(summary.get('passing', 0))],
        ['Failing', str(summary.get('failing', 0))],
        ['Skipped', str(summary.get('skipped', 0))],
        ['Compliance', f"{summary.get('compliance_percentage', 0)}%"],
        ['Status', status],
    ]

    summary_table = Table(summary_data, colWidths=[2*inch, 2*inch])
    summary_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
    ]))
    story.append(summary_table)
    story.append(Spacer(1, 20))

    # Control results
    story.append(Paragraph("Control Results", styles['Heading2']))

    control_data = [['Control ID', 'Status', 'Finding']]
    for control in sorted(controls, key=lambda c: c.get('id', '')):
        ctrl_id = control.get('id', 'Unknown')
        ctrl_status = control.get('status', 'UNKNOWN')
        finding = control.get('finding', '')[:50] + ('...' if len(control.get('finding', '')) > 50 else '')
        control_data.append([ctrl_id, ctrl_status, finding])

    control_table = Table(control_data, colWidths=[1.5*inch, 1*inch, 4*inch])
    control_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.black),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    story.append(control_table)

    # Build PDF
    doc.build(story)
    return True


def main():
    parser = argparse.ArgumentParser(
        description='OSSASAI Compliance Report Generator',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --assessment audit.json
  %(prog)s --assessment audit.json --format yaml --output statement.yaml
  %(prog)s --assessment audit.json --format junit --output results.xml
  %(prog)s --assessment audit.json --format pdf --output report.pdf

Formats:
  text   Plain text report (default)
  json   JSON report with full details
  yaml   YAML compliance statement
  junit  JUnit XML for CI integration
  pdf    PDF report (requires reportlab: pip install reportlab)
"""
    )
    parser.add_argument('--assessment', required=True, help='Path to assessment JSON file')
    parser.add_argument('--evidence', help='Path to evidence directory')
    parser.add_argument('--format', choices=['text', 'json', 'yaml', 'junit', 'pdf'], default='text',
                        help='Output format (default: text)')
    parser.add_argument('--output', '-o', help='Output file path (default: stdout)')
    parser.add_argument('--version', action='version', version=f'%(prog)s {VERSION}')

    args = parser.parse_args()

    # Validate assessment file exists
    if not Path(args.assessment).exists():
        print(f"Error: Assessment file not found: {args.assessment}", file=sys.stderr)
        sys.exit(1)

    try:
        assessment = load_assessment(args.assessment)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in assessment file: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error loading assessment: {e}", file=sys.stderr)
        sys.exit(1)

    # Validate assessment structure
    if 'summary' not in assessment and 'controls' not in assessment:
        print("Error: Assessment file missing required fields (summary or controls)", file=sys.stderr)
        sys.exit(1)

    # Generate report in requested format
    report = None
    if args.format == 'text':
        report = generate_text_report(assessment, args.evidence)
    elif args.format == 'json':
        report = generate_json_report(assessment, args.evidence)
    elif args.format == 'yaml':
        report = generate_yaml_statement(assessment)
    elif args.format == 'junit':
        report = generate_junit_report(assessment)
    elif args.format == 'pdf':
        if not args.output:
            print("Error: PDF format requires --output file path", file=sys.stderr)
            sys.exit(1)
        success = generate_pdf_report(assessment, args.output, args.evidence)
        if success:
            print(f"PDF report written to: {args.output}")
        else:
            # Fallback to text if PDF generation failed
            report = generate_text_report(assessment, args.evidence)
            if args.output:
                text_output = args.output.replace('.pdf', '.txt')
                with open(text_output, 'w') as f:
                    f.write(report)
                print(f"Text report written to: {text_output}")
            else:
                print(report)
        sys.exit(0)
    else:
        print(f"Unknown format: {args.format}", file=sys.stderr)
        sys.exit(1)

    # Output report
    if args.output:
        with open(args.output, 'w') as f:
            f.write(report)
        print(f"Report written to: {args.output}")
    else:
        print(report)


if __name__ == '__main__':
    main()
