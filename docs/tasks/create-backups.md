---
title: How to Create Incremental and Tagged Backups
description: Step-by-step task guide to execute fast, deduplicated, and encrypted backups using Restic CLI, including tags and exclude rules.
author: Portfolio Writing Sample
date: 2026-11-03
tags:
  - task
  - backup
  - incremental
  - cli
---

<span class="topic-badge badge-task">Task</span>

# Create Incremental & Tagged Backups

This procedure walks you through executing backups with Restic. It covers single directories, multi-path sources, exclusion patterns, tagging for compliance, and dry-run safety testing.

---

## Prerequisites

- An initialized repository accessible via `RESTIC_REPOSITORY` and `RESTIC_PASSWORD`.
- Read access to all source directories to be backed up.
- Root or `cap_dac_read_search` capabilities if backing up system directories (`/etc`, `/var`).

---

## Step 1: Perform a Dry-Run Backup

Before transferring files, run a dry-run test using the `--dry-run` flag. This scans the filesystem, evaluates exclusions, and calculates upload metrics without modifying repository data:

```bash
restic backup /var/www/html /etc/nginx \
  --dry-run \
  --verbose
```

Review the dry-run summary:

```text
open repository
repository 82ef1a364b opened (version 2, compression level auto)
created new cache in /home/operator/.cache/restic
[0:02] 1,420 files, 480.20 MiB, 0 errors
Would add to the repository:
  1,420 files
  480.20 MiB

processed 1,420 files, 480.20 MiB in 0:02
```

---

## Step 2: Configure Exclude Rules

Backing up ephemeral caches, sockets, or temp files degrades deduplication and wastes storage. Create an exclusion file:

```bash title="/etc/restic/excludes.txt"
# Version control metadata
.git/
.svn/

# Ephemeral caches and logs
*.tmp
*.log
/var/log/*
__pycache__/
node_modules/
.cache/
```

Pass this file to the backup command using `--exclude-file`:

```bash
restic backup /srv/application \
  --exclude-file=/etc/restic/excludes.txt
```

---

## Step 3: Execute the Backup with Tags and Metadata

Tags categorize snapshots for retention policies and audit logging. For example, add environment and service tags:

```bash
restic backup /var/www/html /etc/nginx \
  --tag "web-tier" \
  --tag "production" \
  --exclude-file=/etc/restic/excludes.txt \
  --verbose
```

### Output Breakdown

```text
repository 82ef1a364b opened (version 2, compression level auto)
using parent snapshot 9a12b3c4
scan [/var/www/html /etc/nginx]
[0:04] 100.00%  1.420 GiB / 1.420 GiB  1,420 / 1,420 items  0 errors  ETA 0:00

Files:           28 new,     12 changed,  1,380 unmodified
Dirs:             2 new,      4 changed,    120 unmodified
Data Blobs:      42 new
Tree Blobs:       6 new
Added to the repository: 14.82 MiB (raw: 42.10 MiB)

processed 1,420 files, 1.420 GiB in 0:04
snapshot 6b3c91af saved
```

Notice the deduplication efficiency: while the source payload is **1.420 GiB**, only **14.82 MiB** was encrypted and written to repository storage.

---

## Step 4: Stream Data Directly via STDIN (Database Dumps)

You can stream uncompressed database backups directly into Restic without staging raw unencrypted SQL dumps onto the local disk:

```bash
pg_dumpall -U postgres | restic backup \
  --stdin \
  --stdin-filename "postgres-full-cluster.sql" \
  --tag "database" \
  --tag "postgres"
```

---

## Step 5: Verify the Created Snapshot

List all snapshots associated with the target tag to confirm the snapshot was registered:

```bash
restic snapshots --tag "production"
```

Expected output:

```text
ID        Time                 Host        Tags                 Paths
-----------------------------------------------------------------------------------------
6b3c91af  2026-11-03 10:45:00  web-prod-01  production,web-tier  /var/www/html, /etc/nginx
-----------------------------------------------------------------------------------------
1 snapshot
```

---

## Next Steps

- [Verify Repository Integrity](verify-integrity.md) — Ensure newly written snapshots pass cryptographic checks.
- [Restore Data](restore-data.md) — Test disaster recovery procedures by restoring files.
