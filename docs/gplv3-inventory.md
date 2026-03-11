# GPLv3 Package Inventory

**Source:** AGL Terrific Trout 19.92.0 / Yocto Scarthgap 5.0
**Machine:** qemuarm64
**Image:** agl-image-minimal
**Scan date:** 2026-03-11
**Manifest:** `tmp/deploy/licenses/qemuarm64/agl-image-minimal-qemuarm64.rootfs/license.manifest`

---

## Summary

| Category | Count |
|---|---|
| candidate_replacement | 5 |
| candidate_exception (GCC runtime) | 2 |
| dual_license (safe to elect GPLv2 side) | 4 |
| **Total GPLv3-touched entries** | **13** |

Notable: `bash` is NOT present — AGL minimal already uses busybox ash.

---

## candidate_replacement — Should be replaced or removed

| Package | Recipe | Version | License | Action |
|---|---|---|---|---|
| `coreutils` | coreutils | 9.4 | GPL-3.0-or-later | Replace with busybox |
| `findutils` | findutils | 4.9.0 | GPL-3.0-or-later | Replace with busybox find |
| `grep` | grep | 3.11 | GPL-3.0-only | Replace with busybox grep |
| `readline` | readline | 8.2 | GPL-3.0-or-later | Replace with libedit or remove |
| `kbd-keymaps-pine` | kbd | 2.6.4 | GPL-3.0-or-later | Exception or remove if no keyboard needed |
| `mc` | mc | 4.8.31 | GPL-3.0-only | Remove (Midnight Commander, non-essential) |
| `screen` | screen | 4.9.1 | GPL-3.0-or-later | Remove (non-essential in minimal image) |

## candidate_exception — GCC Runtime Library Exception applies

| Package | Recipe | License | Notes |
|---|---|---|---|
| `libgcc` | gcc-runtime | GPL-3.0-with-GCC-exception | GCC Runtime Library Exception — safe for distribution |
| `libstdc++` | gcc-runtime | GPL-3.0-with-GCC-exception | GCC Runtime Library Exception — safe for distribution |

The GCC Runtime Library Exception explicitly permits distributing binaries linked against these libraries without GPLv3 obligations. Standard practice is to add them to INCOMPATIBLE_LICENSE_EXCEPTIONS.

## dual_license — Can elect the GPLv2 side

| Package | Recipe | License | Safe election |
|---|---|---|---|
| `gmp` | gmp | GPL-2.0-or-later \| LGPL-3.0-or-later | GPL-2.0-or-later |
| `libidn2` | libidn2 | (GPL-2.0-or-later \| LGPL-3.0-only) & Unicode-DFS-2016 | GPL-2.0-or-later |
| `libunistring` | libunistring | LGPL-3.0-or-later \| GPL-2.0-or-later | GPL-2.0-or-later |
| `nettle` | nettle | LGPL-3.0-or-later \| GPL-2.0-or-later | GPL-2.0-or-later |

These packages have dual licenses. INCOMPATIBLE_LICENSE will block them unless explicitly excepted. The GPLv2 side is available — add them to INCOMPATIBLE_LICENSE_EXCEPTIONS.

---

## Already clean (not in this image)

- bash — AGL minimal uses busybox ash
- gdb / gdbserver — not in minimal image
- gawk — not pulled in
- sed (GNU) — not pulled in
- tar (GNU) — not pulled in
- autoconf / automake — build-only, not in rootfs
