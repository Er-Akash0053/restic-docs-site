---
title: Restic CLI Command Reference & Cheat Sheet
description: Quick lookup cheat sheet of essential Restic commands, global flags, and environment variables.
author: Portfolio Writing Sample
date: 2026-11-03
tags:
  - reference
  - cli
  - flags
  - cheat-sheet
---

<span class="topic-badge badge-reference">Reference</span>

# CLI Command Reference & Cheat Sheet

This reference provides a fast lookup guide for everyday Restic CLI commands, global options, and standard environment variables.

---

## Environment Variables

| Variable | Description | Example |
| :--- | :--- | :--- |
| `RESTIC_REPOSITORY` | Location of the target repository | `/mnt/backup`, `s3:https://s3.amazonaws.com/my-bucket` |
| `RESTIC_PASSWORD` | Plaintext repository password | `TopSecret123!` |
| `RESTIC_PASSWORD_FILE` | Path to a file containing the password | `/etc/restic/pwd.txt` |
| `RESTIC_PASSWORD_COMMAND` | Command executed to output the password | `pass show backup/restic` |
| `RESTIC_CACHE_DIR` | Directory used to cache pack headers and indexes | `/tmp/restic-cache` |
| `AWS_ACCESS_KEY_ID` | Access key for S3 backends | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | Secret key for S3 backends | `wJalr...` |

---

## Global CLI Options

These flags apply to virtually all Restic commands:

| Flag | Short | Description |
| :--- | :--- | :--- |
| `--repo <URI>` | `-r` | Target repository location (overrides `RESTIC_REPOSITORY`). |
| `--password-file <PATH>` | `-p` | Read master password from specified file. |
| `--json` | | Output command results in machine-readable JSON format. |
| `--verbose` | `-v` | Increase verbosity level (can be passed twice `-vv`). |
| `--quiet` | `-q` | Suppress non-error status output (recommended for cron). |
| `--no-cache` | | Disable local metadata caching. |
| `--no-lock` | | Open repository without acquiring shared locks (read-only). |

---

## Command Reference Matrix

### Repository Lifecycle

```bash
# Initialize a new repository
restic init

# Add a secondary password key
restic key add

# List all authorized keys
restic key list

# Remove a compromised key
restic key remove <KEY_ID>
```

### Backup Operations

```bash
# Standard backup with tag
restic backup /path/to/data --tag production

# Dry-run backup inspection
restic backup /path/to/data --dry-run

# Exclude patterns and files
restic backup /path/to/data --exclude="*.log" --exclude-file=excludes.txt

# Stream from standard input
mysqldump --all-databases | restic backup --stdin --stdin-filename dump.sql
```

### Snapshot Management

```bash
# List all snapshots
restic snapshots

# Filter snapshots by tag and host
restic snapshots --tag production --host web-01

# Inspect file tree of a snapshot
restic ls latest

# Display repository storage statistics
restic stats --mode raw-data
```

### Verification & Recovery

```bash
# Lightweight metadata integrity check
restic check

# Full cryptographic bit-rot audit
restic check --read-data

# Restore latest snapshot to destination directory
restic restore latest --target /tmp/recovery

# Mount repository via FUSE
restic mount /mnt/restic
```

### Retention & Maintenance

```bash
# Preview retention policy removal
restic forget --keep-daily 7 --keep-weekly 4 --dry-run

# Execute policy and prune orphaned blobs
restic forget --keep-daily 7 --keep-weekly 4 --prune

# Unlock repository after an abnormal worker exit
restic unlock
```
