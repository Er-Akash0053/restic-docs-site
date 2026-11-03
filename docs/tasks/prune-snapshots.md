---
title: How to Enforce Retention Policies and Prune Data
description: Step-by-step task guide to automate snapshot retention with restic forget and reclaim storage space with restic prune.
author: Portfolio Writing Sample
date: 2026-11-03
tags:
  - task
  - retention
  - prune
  - maintenance
---

<span class="topic-badge badge-task">Task</span>

# Enforce Retention Policies & Prune Data

This procedure explains how to apply retention policies to clean up old backup snapshots and physically reclaim disk space by pruning orphaned pack files.

---

## Prerequisites

- Read and write permissions on the repository storage backend.
- Exclusive access or scheduling outside active backup windows to prevent lock contention.

---

## Step 1: Preview Retention Policy with `--dry-run`

Never execute retention pruning without first previewing which snapshots will be preserved and which will be deleted:

```bash
restic forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12 \
  --dry-run
```

### Reviewing the Policy Evaluation Table

Restic prints an ASCII matrix illustrating its decision for every snapshot:

```text
Applying Policy: keep the last 7 daily, 4 weekly, 12 monthly snapshots
keep 3 snapshots:
ID        Time                 Host        Tags        Reasons
-------------------------------------------------------------------------
6b3c91af  2026-11-03 10:45:00  web-prod-01  production  daily snapshot
e49f012a  2026-11-02 10:45:00  web-prod-01  production  daily snapshot
9a12b3c4  2026-10-26 10:45:00  web-prod-01  production  weekly snapshot
-------------------------------------------------------------------------

remove 1 snapshots:
ID        Time                 Host        Tags        Reasons
-------------------------------------------------------------------------
3c8e19b0  2026-09-01 10:45:00  web-prod-01  production  
-------------------------------------------------------------------------

1 snapshots have been removed, run `prune` to reclaim space.
```

---

## Step 2: Apply the Retention Policy (`forget`)

Once the dry-run output matches your compliance requirements, execute the policy without `--dry-run`:

```bash
restic forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12
```

This dereferences expired snapshots. As explained in [Retention & Pruning Lifecycle](../concepts/retention-and-pruning.md), this step deletes the snapshot descriptors but does **not** free raw disk space yet.

---

## Step 3: Physically Reclaim Storage (`prune`)

Run the `prune` command to garbage-collect orphaned blobs, repack fragmented pack files, and delete obsolete data:

```bash
restic prune
```

### Prune Summary Output

```text
repository 82ef1a364b opened (version 2, compression level auto)
loading indexes...
loading all snapshots...
finding data that is still in use for 3 snapshots
[0:06] 100.00%  3 / 3 snapshots
searching used packs...
collecting packs for repack and prune...
repacking packs:
[0:02] 100.00%  4 / 4 packs repacked
rebuilding index:
[0:01] 100.00%  1 / 1 indexes rebuilt
deleting obsolete index files:
[0:00] 100.00%  2 / 2 index files removed
removing 18 old packs...
[0:01] 100.00%  18 / 18 packs removed
done, reclaimed 4.821 GiB (78.4% of repository)
```

---

## Step 4: Combined Single-Step Maintenance Command

To streamline routine maintenance in scheduled cron jobs, combine both operations using the `--prune` flag:

```bash
restic forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12 \
  --prune
```

> [!TIP]
> Run `restic forget --prune` during low-traffic maintenance windows. The `prune` phase requires an exclusive lock and temporary additional scratch bandwidth for repacking packs.

---

## Next Steps

- [CLI Command Cheat Sheet](../reference/cli-cheat-sheet.md) — Fast reference of retention flags.
- [Error Codes & Troubleshooting](../reference/error-troubleshooting.md) — What to do if `prune` fails due to lock timeouts.
