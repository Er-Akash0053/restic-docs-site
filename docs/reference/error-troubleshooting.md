---
title: Troubleshooting Matrix & Error Resolution
description: Diagnostic procedures and recovery steps for common Restic errors including repository lock contention, corrupted indexes, and key failures.
author: Portfolio Writing Sample
date: 2026-11-03
tags:
  - reference
  - troubleshooting
  - errors
  - recovery
---

<span class="topic-badge badge-reference">Reference</span>

# Troubleshooting Matrix & Error Resolution

This guide provides diagnostic workflows and resolution steps for common errors encountered during Restic operations.

---

## Error Matrix Summary

| Symptom / Error Message | Root Cause | Immediate Action |
| :--- | :--- | :--- |
| `unable to create lock: repository is already locked` | Stale lock file left by interrupted process | Verify no other active backup is running, then execute `restic unlock`. |
| `ciphertext verification failed` / `wrong password?` | Wrong password provided or repository header corruption | Verify secret string in key vault; check `restic key list`. |
| `pack file not found in index` | Incomplete or interrupted `prune` run desynchronized index | Run `restic rebuild-index`. |
| `fuse: device not found` | FUSE kernel module not loaded on Linux host | Install `fuse3` and run `modprobe fuse`. |
| `file has changed while reading` | Active log or database file mutated during read | Use filesystem snapshots (LVM/ZFS) or stream via `--stdin`. |

---

## Detailed Diagnostic & Resolution Steps

### 1. Resolving Repository Lock Contention

#### Symptom
```text
Fatal: unable to create lock in backend: repository is already locked by PID 4091 on host web-01
```

#### Diagnostic
1. Verify whether the process ID `4091` on host `web-01` is actively running:
   ```bash
   ps aux | grep restic
   ```
2. If the PID is still actively transferring files, **wait for it to complete**.

#### Resolution
If the machine rebooted or the container was killed, the lock is stale:

```bash
# Remove stale locks
restic unlock
```

If multiple stale locks persist, run:

```bash
restic unlock --remove-all
```

---

### 2. Rebuilding a Corrupted Index

#### Symptom
```text
load indexes
error: index file 7b1c4e9a contains errors: pack not found
```

#### Diagnostic
An abnormal interruption during a prune or network failure during an S3 write may leave index files referencing incomplete packs.

#### Resolution
1. Re-read all physical pack files in `data/` and generate a fresh, synchronized index:
   ```bash
   restic rebuild-index
   ```
2. Run a full repository verification check:
   ```bash
   restic check
   ```

---

### 3. Ciphertext Verification Failure

#### Symptom
```text
Fatal: Decrypt: ciphertext verification failed
```

#### Diagnostic
This error occurs when:
- The supplied password is incorrect.
- The key file in `keys/` is truncated or corrupted on disk.
- Hardware bit-rot has corrupted the repository `config` file.

#### Resolution
1. Verify your credentials by opening the repository with `--no-cache`:
   ```bash
   restic -r /path/to/repo --no-cache snapshots
   ```
2. If you have configured a secondary recovery key (as recommended in [Initialize a Repository](../tasks/initialize-repository.md#step-4-add-a-secondary-recovery-key-recommended)), attempt unlocking with the secondary key.

---

### 4. Handling Files Changing During Backup

#### Symptom
```text
warning: /var/log/syslog has changed while reading, backup will contain inconsistent state
```

#### Diagnostic
Restic reads files sequentially. If an active daemon continuously appends to an open file, the file size when scanning will differ from the size when chunking.

#### Resolution
- Exclude active log files using `--exclude="*.log"`.
- For transactional databases (PostgreSQL, MySQL), do **not** back up raw data directories directly. Instead, pipe consistent database dumps via `--stdin`:
  ```bash
  pg_dumpall | restic backup --stdin --stdin-filename postgres.sql
  ```
