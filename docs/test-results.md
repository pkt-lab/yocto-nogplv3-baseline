# GPLv3 Removal — Test Results Comparison

**Target:** AGL Scarthgap 5.0 / `agl-image-minimal` / `virtio-aarch64`
**Build date:** 2026-03-11
**Config:** `INCOMPATIBLE_LICENSE:class-target = "GPL-3.0* LGPL-3.0* AGPL-3.0*"`

---

## Scan Summary

The `gplv3-scan.sh` script inspects the Yocto `pkgdata` license database for
**all packages built** (not just those installed). The before/after counts are
identical because the same recipes are built — exclusion happens at rootfs
assembly, not at recipe compile time.

The rootfs manifest is the authoritative source for what was actually installed.

---

## Phase 3 Build Outcome

| Package | License | In Rootfs? | Status |
|---------|---------|-----------|--------|
| `coreutils` | GPL-3.0-or-later | **No** | ✅ Excluded by INCOMPATIBLE_LICENSE |
| `coreutils-stdbuf` | GPL-3.0-or-later | **No** | ✅ Excluded |
| `findutils` | GPL-3.0-or-later | **No** | ✅ Excluded |
| `grep` | GPL-3.0-only | **No** | ✅ Excluded |
| `mc` | GPL-3.0-only | **No** | ✅ Excluded via IMAGE_INSTALL:remove |
| `screen` | GPL-3.0-or-later | **No** | ✅ Excluded via IMAGE_INSTALL:remove |
| `readline` | GPL-3.0-or-later | **No** | ✅ Excluded (connman-client PACKAGECONFIG removed) |
| `kbd-keymaps-pine` | GPL-3.0-or-later | **No** | ✅ Excluded via BAD_RECOMMENDATIONS |
| `libgcc1` | GPL-3.0-with-GCC-exception | **Yes** | ✅ Allowed by INCOMPATIBLE_LICENSE_EXCEPTIONS |
| `libstdc++6` | GPL-3.0-with-GCC-exception | **Yes** | ✅ Allowed by INCOMPATIBLE_LICENSE_EXCEPTIONS |
| `libgmp10` | GPL-2.0-or-later \| LGPL-3.0-or-later | **Yes** | ✅ Dual-license — GPL-2.0 path elected |
| `libidn2-0` | (GPL-2.0-or-later \| LGPL-3.0-only) & Unicode | **Yes** | ✅ Dual-license — GPL-2.0 path elected |
| `libunistring5` | LGPL-3.0-or-later \| GPL-2.0-or-later | **Yes** | ✅ Dual-license — GPL-2.0 path elected |
| `nettle` | LGPL-3.0-or-later \| GPL-2.0-or-later | **Yes** | ✅ Dual-license — GPL-2.0 path elected |

**Result: 0 pure GPL-3.0/LGPL-3.0 packages in the final rootfs.**

---

## Bugs Fixed During Phase 3

### Bug 1: `connman-client` missing from RPM repo
- **Root cause:** `readline` (GPL-3.0-or-later) is PACKAGECONFIG dependency
  of `connman-client`. When readline is excluded, connman builds without the
  client binary and no `connman-client` RPM is produced.
- **Fix:** Added `connman_%.bbappend` disabling `PACKAGECONFIG[client]` AND
  added `packagegroup-agl-core-connectivity.bbappend` removing `connman-client`
  from `RDEPENDS` so rootfs assembly succeeds.

### Bug 2: `kbd-keymaps` incorrectly in `BAD_RECOMMENDATIONS`
- **Root cause:** `kbd-keymaps` is GPL-2.0-or-later (not GPL-3.0). Only
  `kbd-keymaps-pine` is GPL-3.0-or-later. The original config incorrectly
  excluded `kbd` and `kbd-keymaps`, which caused `systemd-vconsole-setup`
  (hard RDEPEND on `kbd-keymaps`) to fail during rootfs assembly.
- **Fix:** Updated `BAD_RECOMMENDATIONS` to exclude only `dosfstools` and
  `kbd-keymaps-pine`.

---

## Build Warnings (non-blocking)

| Warning | Impact |
|---------|--------|
| `squish_7.2` produces empty packages | Qt test tool, not part of image |
| `qemu-system-native: invalid PACKAGECONFIG: glx` | Build-host only, no product impact |

---

## Config Applied (local.conf additions)

```bitbake
# GPLv3 removal baseline (yocto-nogplv3-baseline Phase 3)
INCOMPATIBLE_LICENSE:class-target = "GPL-3.0* LGPL-3.0* AGPL-3.0*"
VIRTUAL-RUNTIME_base-utils = "busybox"
VIRTUAL-RUNTIME_login_manager = "busybox"
INCOMPATIBLE_LICENSE_EXCEPTIONS = "GPL-3.0-with-GCC-exception LGPL-3.0-with-GCC-exception"
IMAGE_INSTALL:remove = "screen mc"
IMAGE_FEATURES:remove = "tools-debug tools-profile package-management"
IMAGE_INSTALL:append = " dash"
BAD_RECOMMENDATIONS += "dosfstools kbd-keymaps-pine"
MACHINE_FEATURES:remove = "vfat"
```

See `docs/local.conf.example` for the full annotated reference configuration.
