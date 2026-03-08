# Documentation

Write and structure documentation using the Diataxis framework. Thomas prefers well-organized docs that serve distinct purposes.

## When to use

- When writing READMEs, runbooks, guides, or reference docs
- When Thomas says "document this", "write docs", "add documentation"
- When creating any file that is primarily documentation

## Diataxis Framework

All documentation should map to one of these four types:

### Tutorials (Learning-oriented)
- **Purpose**: Help a newcomer get started
- **Style**: Step-by-step, hand-holding, "follow along"
- **Example**: "Setting up the dev environment from scratch"
- **Verb**: Learn

### How-to Guides (Task-oriented)
- **Purpose**: Help someone accomplish a specific goal
- **Style**: Practical steps, assumes some knowledge
- **Example**: "How to add a new NixOS module"
- **Verb**: Do

### Reference (Information-oriented)
- **Purpose**: Describe the system accurately and completely
- **Style**: Dry, factual, comprehensive
- **Example**: "Configuration options for zeroclaw.nix"
- **Verb**: Look up

### Explanation (Understanding-oriented)
- **Purpose**: Explain why things work the way they do
- **Style**: Discursive, contextual, big-picture
- **Example**: "Why we use declarative deployment for skills"
- **Verb**: Understand

## Writing Guidelines

1. **Identify the type first.** Don't mix tutorial and reference in one doc.

2. **One file, one purpose.** If a doc is trying to be both a tutorial and reference, split it.

3. **Use concrete examples.** Show actual commands, actual file paths, actual output.

4. **No filler.** Every sentence should carry information. Cut "In this section we will discuss..."

5. **Keep it current.** Outdated docs are worse than no docs. Update or delete.

6. **Link, don't repeat.** Reference other docs instead of duplicating content.

## Document Structure

```markdown
# Title

One-line summary of what this document covers.

## [Sections appropriate to the doc type]

### For tutorials:
## Prerequisites
## Step 1: ...
## Step 2: ...
## What you've learned

### For how-to guides:
## Problem/Goal
## Steps
## Troubleshooting

### For reference:
## Overview
## [Organized by topic/API/module]

### For explanation:
## Context
## [Discussion sections]
## Summary
```

## Notes

- Thomas's repos use Conventional Commits and Markdown
- CLAUDE.md files are a hybrid of reference + how-to — that's fine for repo instructions
- Prefer editing existing docs over creating new ones
- Check for existing docs before writing — don't create duplicates
