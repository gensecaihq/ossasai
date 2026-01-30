#!/usr/bin/env python3
"""
Convert Mintlify .mdx files to plain GitHub-flavored markdown.
Removes Mintlify-specific components and converts them to standard markdown.
"""

import os
import re
import glob

def convert_note_warning(content):
    """Convert <Note> and <Warning> to blockquotes."""
    # <Note>content</Note> -> > **Note:** content
    content = re.sub(
        r'<Note>\s*(.*?)\s*</Note>',
        lambda m: '> **Note:** ' + m.group(1).replace('\n', '\n> '),
        content,
        flags=re.DOTALL
    )

    # <Warning>content</Warning> -> > **Warning:** content
    content = re.sub(
        r'<Warning>\s*(.*?)\s*</Warning>',
        lambda m: '> **Warning:** ' + m.group(1).replace('\n', '\n> '),
        content,
        flags=re.DOTALL
    )

    # <Info>content</Info> -> > **Info:** content
    content = re.sub(
        r'<Info>\s*(.*?)\s*</Info>',
        lambda m: '> **Info:** ' + m.group(1).replace('\n', '\n> '),
        content,
        flags=re.DOTALL
    )

    return content

def convert_card_group(content):
    """Convert <CardGroup> to nothing (just keep inner content)."""
    content = re.sub(r'<CardGroup[^>]*>', '', content)
    content = re.sub(r'</CardGroup>', '', content)
    return content

def convert_cards(content):
    """Convert <Card> components to markdown sections."""
    # Match Card with title and optional href
    def replace_card(match):
        full_match = match.group(0)
        inner = match.group(1)

        # Extract title if present
        title_match = re.search(r'title="([^"]*)"', full_match.split('>')[0])
        href_match = re.search(r'href="([^"]*)"', full_match.split('>')[0])

        title = title_match.group(1) if title_match else None
        href = href_match.group(1) if href_match else None

        if title and href:
            # Convert href from .mdx to .md
            href = href.replace('.mdx', '.md')
            return f'### [{title}]({href})\n\n{inner.strip()}\n'
        elif title:
            return f'### {title}\n\n{inner.strip()}\n'
        else:
            return inner.strip()

    # Handle multi-line Card components
    content = re.sub(
        r'<Card[^>]*>\s*(.*?)\s*</Card>',
        replace_card,
        content,
        flags=re.DOTALL
    )

    return content

def convert_accordion_group(content):
    """Convert <AccordionGroup> to nothing (just keep inner content)."""
    content = re.sub(r'<AccordionGroup>', '', content)
    content = re.sub(r'</AccordionGroup>', '', content)
    return content

def convert_accordions(content):
    """Convert <Accordion> components to details/summary or headers."""
    def replace_accordion(match):
        full_match = match.group(0)
        inner = match.group(1)

        # Extract title
        title_match = re.search(r'title="([^"]*)"', full_match.split('>')[0])
        title = title_match.group(1) if title_match else "Details"

        # Use details/summary for better GitHub rendering
        return f'<details>\n<summary><strong>{title}</strong></summary>\n\n{inner.strip()}\n\n</details>\n'

    content = re.sub(
        r'<Accordion[^>]*>\s*(.*?)\s*</Accordion>',
        replace_accordion,
        content,
        flags=re.DOTALL
    )

    return content

def convert_steps(content):
    """Convert <Steps> and <Step> to numbered lists."""
    # First, handle Steps wrapper
    content = re.sub(r'<Steps>', '', content)
    content = re.sub(r'</Steps>', '', content)

    # Convert Step components to numbered list items
    step_counter = [0]  # Use list to allow mutation in closure

    def replace_step(match):
        full_match = match.group(0)
        inner = match.group(1)
        step_counter[0] += 1

        # Extract title
        title_match = re.search(r'title="([^"]*)"', full_match.split('>')[0])
        title = title_match.group(1) if title_match else f"Step {step_counter[0]}"

        # Format as numbered item with bold title
        inner_formatted = inner.strip().replace('\n', '\n   ')
        return f'{step_counter[0]}. **{title}**\n\n   {inner_formatted}\n'

    content = re.sub(
        r'<Step[^>]*>\s*(.*?)\s*</Step>',
        replace_step,
        content,
        flags=re.DOTALL
    )

    return content

def convert_tabs(content):
    """Convert <Tabs> and <Tab> to sections with headers."""
    # Remove Tabs wrapper
    content = re.sub(r'<Tabs>', '', content)
    content = re.sub(r'</Tabs>', '', content)

    # Convert Tab components to sections
    def replace_tab(match):
        full_match = match.group(0)
        inner = match.group(1)

        # Extract title
        title_match = re.search(r'title="([^"]*)"', full_match.split('>')[0])
        title = title_match.group(1) if title_match else "Tab"

        return f'**{title}:**\n\n{inner.strip()}\n\n'

    content = re.sub(
        r'<Tab[^>]*>\s*(.*?)\s*</Tab>',
        replace_tab,
        content,
        flags=re.DOTALL
    )

    return content

def update_internal_links(content):
    """Update internal links from .mdx to .md."""
    # Update links in markdown format [text](path.mdx) -> [text](path.md)
    content = re.sub(r'\]\(([^)]+)\.mdx\)', r'](\1.md)', content)

    # Also update bare paths that might reference .mdx
    content = re.sub(r'href="([^"]+)\.mdx"', r'href="\1.md"', content)

    return content

def clean_frontmatter(content):
    """Clean up frontmatter, keeping title and description."""
    # The frontmatter is already in a good format, just keep it
    return content

def convert_file(input_path, output_path):
    """Convert a single .mdx file to .md."""
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Apply conversions in order
    content = convert_note_warning(content)
    content = convert_card_group(content)
    content = convert_cards(content)
    content = convert_accordion_group(content)
    content = convert_accordions(content)
    content = convert_steps(content)
    content = convert_tabs(content)
    content = update_internal_links(content)
    content = clean_frontmatter(content)

    # Clean up extra whitespace
    content = re.sub(r'\n{4,}', '\n\n\n', content)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Converted: {input_path} -> {output_path}")

def main():
    """Main function to convert all .mdx files."""
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    # Find all .mdx files
    mdx_files = glob.glob(os.path.join(base_dir, '**/*.mdx'), recursive=True)

    for mdx_file in mdx_files:
        # Skip files in tools directory
        if '/tools/' in mdx_file:
            continue

        # Create output path
        md_file = mdx_file.replace('.mdx', '.md')

        # Convert the file
        convert_file(mdx_file, md_file)

        # Remove the original .mdx file
        os.remove(mdx_file)
        print(f"Removed: {mdx_file}")

if __name__ == '__main__':
    main()
