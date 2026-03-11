# yocto-nogplv3-baseline

Reference configuration and tooling for removing GPL-3.0 / LGPL-3.0 packages
from an AGL Scarthgap 5.0 (`agl-image-minimal`, `qemuarm64`) build.

**AGL release:** Terrific Trout 19.92.0
**Yocto release:** Scarthgap 5.0
**Target machine:** qemuarm64
**Scan date:** 2026-03-11

---

## What this repository contains

| File | Purpose |
|---|---|
| `docs/gplv3-inventory.md` | Full inventory of all 14 GPLv3-touched packages found in the image, with categories |
| `docs/gplv3-replacement-matrix.md` | Per-package replacement strategy, risk level, and validation steps |
| `docs/local.conf.example` | Drop-in `conf/local.conf` fragment with `INCOMPATIBLE_LICENSE` settings |
| `docs/distro-snippets.conf` | Distro layer `.conf` fragment for team-wide enforcement |
| `docs/known-issues.md` | Documented edge cases, gaps, and workarounds |
| `scripts/gplv3-scan.sh` | Bash script to scan any Yocto build directory for GPLv3 packages |

---

## Quick start

### 1. Scan your build

```sh
./scripts/gplv3-scan.sh /path/to/your/yocto/build
```

The script exits 0 if no `target_runtime` GPLv3 packages are found, non-zero otherwise.
Suitable as a CI gate.

### 2. Apply the license policy

Copy the relevant blocks from `docs/local.conf.example` into your
`build/conf/local.conf`, or `require` `docs/distro-snippets.conf` from your
distro configuration.

### 3. Read the replacement matrix

`docs/gplv3-replacement-matrix.md` lists every GPLv3 package, its recommended
replacement, compatibility risk, and step-by-step validation instructions.

---

## GPLv3 package summary (as-found)

| Category | Count | Packages |
|---|---|---|
| target_runtime (must address) | 8 | coreutils, coreutils-stdbuf, findutils, grep, kbd-keymaps-pine, mc, readline, screen |
| candidate_exception (GCC RLE) | 2 | libgcc, libstdc++ |
| dual_license (elect GPLv2 side) | 4 | gmp, libidn2, libunistring, nettle |
| **Total** | **14** | |

**Notable:** `bash` is not present — AGL minimal already uses busybox ash.

---

## Remediation approach

1. **Block at distro level** — `INCOMPATIBLE_LICENSE:class-target` in distro conf.
2. **Exempt GCC runtime** — `libgcc`, `libstdc++` via `INCOMPATIBLE_LICENSE_EXCEPTIONS`.
3. **Dual-license election** — `gmp`, `libidn2`, `libunistring`, `nettle` elect GPLv2 path.
4. **Replace with busybox** — `coreutils`, `findutils`, `grep` (busybox already in AGL).
5. **Remove optional tools** — `mc`, `screen` (non-essential in minimal image).
6. **Replace readline** — with `libedit` (BSD-3-Clause); patch dependents.
7. **Audit kbd** — drop `kbd-keymaps-pine` for headless targets.

See `docs/known-issues.md` for pitfalls with each step.

---

## Running the scan in CI

```yaml
# Example GitHub Actions step
- name: GPLv3 compliance check
  run: |
    bash scripts/gplv3-scan.sh "$YOCTO_BUILD_DIR" && echo "PASS" || \
      (echo "FAIL: GPLv3 packages found — see scan output above"; exit 1)
```

The script writes a text report to `gplv3-report.txt` by default.
Pass a second argument to change the output path.
