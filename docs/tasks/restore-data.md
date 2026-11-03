---
title: How to Restore Files and Mount Snapshots
description: Step-by-step task guide to recover files from Restic snapshots, perform selective file restores, and mount snapshots via FUSE.
author: Portfolio Writing Sample
date: 2026-11-03
tags:
  - task
  - restore
  - recovery
  - fuse
---

<span class="topic-badge badge-task">Task</span>

# Restore Files & Mount Snapshots

This procedure walks you through recovering data from a Restic repository. It covers snapshot identification, complete directory restores, granular single-file recovery, path filtering, and mounting snapshots as a virtual filesystem with FUSE.

---

## Prerequisites

- Read access to the Restic repository.
- Adequate free disk space on the target destination path to accommodate the uncompressed restored payload.
- `fuse3` package installed if using the virtual mount capability.

---

## Step 1: Identify the Target Snapshot

Query your repository to locate the snapshot containing the files you need to restore:

```bash
restic snapshots --path "/var/www/html"
```

Sample output:

```text
ID        Time                 Host        Tags         Paths
----------------------------------------------------------------------
6b3c91af  2026-11-03 10:45:00  web-prod-01  production   /var/www/html
e49f012a  2026-11-02 10:45:00  web-prod-01  production   /var/www/html
----------------------------------------------------------------------
```

Note the snapshot ID (e.g., `6b3c91af` or use the alias `latest`).

---

## Step 2: Inspect Snapshot Contents

Before initiating a restore, inspect the file tree within the snapshot:

```bash
restic ls 6b3c91af
```

To search for a specific filename within a snapshot:

```bash
restic find config.php --snapshot 6b3c91af
```

---

## Step 3: Perform a Complete Restore

Restore the entire contents of a snapshot into an isolated staging directory:

```bash
mkdir -p /mnt/restore-staging
restic restore 6b3c91af --target /mnt/restore-staging
```

Expected output:

```text
repository 82ef1a364b opened (version 2, compression level auto)
restoring <Snapshot 6b3c91af of [/var/www/html] at 2026-11-03 10:45:00.000 by operator@web-prod-01> to /mnt/restore-staging
summary: 1,420 files, 120 dirs, 1.420 GiB restored in 0:03
```

---

## Step 4: Selective Granular Restore (Single File or Directory)

When you only need a specific configuration file or subfolder, use the `--include` flag:

```bash
restic restore latest \
  --target /tmp/recovery \
  --include "/var/www/html/wp-config.php"
```

Verify that only the requested file was restored:

```bash
ls -la /tmp/recovery/var/www/html/wp-config.php
```

---

## Step 5: Mount Snapshots via FUSE (Interactive Browse)

On Linux and macOS, you can mount the entire repository as a read-only filesystem. This lets users browse historical snapshots using standard terminal tools (`cd`, `cat`, `grep`, `cp`):

1. Create a local mount directory:
   ```bash
   mkdir -p /mnt/restic-mount
   ```

2. Mount the repository:
   ```bash
   restic mount /mnt/restic-mount &
   ```

3. Browse through point-in-time snapshots:
   ```bash
   ls -la /mnt/restic-mount/snapshots/
   ```

   ```text
   total 0
   dr-xr-xr-x 1 root root 0 Nov  3 10:45 2026-11-03T10:45:00+00:00
   dr-xr-xr-x 1 root root 0 Nov  2 10:45 2026-11-02T10:45:00+00:00
   lrwxr-xr-x 1 root root 0 Nov  3 10:45 latest -> 2026-11-03T10:45:00+00:00
   ```

4. Unmount when finished:
   ```bash
   fusermount -u /mnt/restic-mount
   ```

---

## Next Steps

- [Prune & Enforce Retention](prune-snapshots.md) — Learn how to purge obsolete snapshots.
- [Error Codes & Troubleshooting](../reference/error-troubleshooting.md) — Resolve permissions and mount errors.
