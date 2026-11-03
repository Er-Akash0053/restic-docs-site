# Restic Technical Documentation & Storage Architecture

> **Technical Writing Sample & Docs-as-Code Portfolio Project**  
> *Target Domain:* Cloud Storage, Infrastructure, Backup & Disaster Recovery  
> *Framework:* MkDocs Material + Markdown + Mermaid.js + GitHub Pages CI/CD  
> *Architecture:* Topic-Based Authoring (Diátaxis / DITA Standards)

---

## Portfolio Overview

This project serves as an end-to-end writing sample demonstrating how to take complex, low-level open-source backup software (**Restic**) and architect production-grade, topic-based documentation. 

Rather than a monolithic manual, this documentation is structured into four distinct cognitive archetypes:

1. **Concepts**: Deep architectural explanations (AES-256/Poly1305 cryptography, content-defined chunking with Rabin fingerprints, two-phase forget/prune lifecycle).
2. **Tasks**: Prescriptive, tested procedures with prerequisites, step-by-step commands, expected outputs, and verification (e.g., repository initialization, multi-tier integrity checks with `--read-data`, granular restores).
3. **Reference**: Authoritative, low-friction lookup tables (CLI flags, environment variables, diagnostic matrices for stale locks and index corruption).
4. **Release Notes**: Structured changelogs (v0.17.0) with executive summaries, code examples, deprecation warnings, and upgrade paths.

---

## Directory Layout

```
project-1-docs-site/
├── .github/
│   └── workflows/
│       └── deploy-docs.yml      # Automated GitHub Pages CI/CD pipeline
├── docs/
│   ├── index.md                 # IA entry point and overview
│   ├── concepts/                # Mental models & architectural theory
│   │   ├── architecture.md      # Zero-trust crypto, pack files, tree DAG
│   │   ├── deduplication.md     # CDC, rolling Rabin checksums
│   │   └── retention-and-pruning.md # Two-stage lifecycle, pack repacking
│   ├── tasks/                   # Actionable, tested how-to guides
│   │   ├── initialize-repository.md
│   │   ├── create-backups.md
│   │   ├── verify-integrity.md
│   │   ├── restore-data.md
│   │   └── prune-snapshots.md
│   ├── reference/               # Syntax and lookup tables
│   │   ├── cli-cheat-sheet.md
│   │   └── error-troubleshooting.md
│   ├── release-notes/           # Version changelogs & migration guides
│   │   └── v0-17-0.md
│   └── assets/
│       └── custom.css           # Custom styling for badges and layout
├── mkdocs.yml                   # MkDocs Material configuration
├── requirements.txt             # Python dependencies
├── .gitignore
└── README.md
```

---

## Local Development & Build Verification

### 1. Prerequisites
- Python 3.10+
- `pip`

### 2. Environment Setup
```bash
# Create and activate virtual environment
python -m venv venv

# Windows:
.\venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Run Local Dev Server
```bash
mkdocs serve
```
Open your browser at `http://127.0.0.1:8000` to preview the site with live reloading.

### 4. Strict Build Validation
Run strict build validation to ensure zero broken links, invalid tags, or syntax errors:
```bash
mkdocs build --strict
```
This generates the static HTML distribution inside the `site/` directory.

---

## GitHub Actions & GitHub Pages Deployment

The repository includes a ready-to-run GitHub Actions workflow (`.github/workflows/deploy-docs.yml`):

1. **Trigger**: Triggers automatically on pushes to `main` or pull requests.
2. **Build Gate**: Executes `mkdocs build --strict` inside `ubuntu-latest`. Any dead internal link or YAML configuration error fails the pipeline.
3. **Deployment**: When merged to `main`, executes `mkdocs gh-deploy` to automatically publish the site to GitHub Pages.

---

## Writing Principles Applied

- **Information Architecture**: Applied Diátaxis framework separating concepts (why/what) from tasks (how-to) and references (lookups).
- **Style Guide Alignment**: Adheres to Google Developer Documentation Style Guide (imperative mood, second-person "you", active voice, sentence casing).
- **Tested Technical Accuracy**: Every CLI command, flag sequence, and diagnostic output was tested and validated.
- **Visual Scannability**: Utilizes Mermaid sequence diagrams, flowcharts, code tabs, and admonitions to reduce cognitive load.
