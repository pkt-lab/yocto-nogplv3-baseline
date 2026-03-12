# Known Issues — GPLv3 Removal / AGL Scarthgap 5.0

## 1. coreutils — busybox applet gaps

**Issue:** Some GNU coreutils long-options are absent from busybox.

Affected applets: `sort --version-sort`, `ls --group-directories-first`,
`cp --reflink`, `date --iso-8601`.

**Impact:** Init scripts or tooling that rely on these flags will fail silently
or with an unrecognised option error.

**Mitigation:** Audit all shell scripts in the image with:
```sh
grep -r 'coreutils\|--version-sort\|--group-directories' /etc /lib/systemd
```
Rewrite affected scripts to use POSIX-compatible flags.

---

## 2. findutils — `-printf` and `-perm /mode` not in busybox find

**Issue:** `busybox find` does not implement `-printf` or the `+mode` octal
permission syntax (use `/mode` instead).

**Impact:** Any script using `find ... -printf '%f\n'` will fail.

**Mitigation:** Replace `-printf` with `-exec printf '%f\n' {} \;` or rewrite
using `awk`/`sed` post-processing.

---

## 3. readline — libedit API differences

**Issue:** `libedit` provides `editline/readline.h` compatibility but the
following functions are absent or behave differently:

- `rl_completion_entry_function` (different signature)
- `rl_event_hook`
- History file locking

**Known affected recipes:** `bash`, `python3`, `sqlite3`, `gdb`.

**Mitigation:** Each dependent recipe needs a bbappend adding
`--with-libedit` or `--without-readline` to `EXTRA_OECONF`. Test
interactively before shipping. If a package cannot be patched, add
`readline:GPL-3.0-or-later` to `INCOMPATIBLE_LICENSE_EXCEPTIONS` as a
last resort and document the exception.

---

## 4. gmp / libidn2 / libunistring / nettle — dual-license election not always honoured

**Issue:** Some older versions of these recipes do not implement the Yocto
dual-license selection mechanism. Bitbake may still report the LGPL-3.0
license in the manifest even after adding the exception.

**Verification:**
```sh
bitbake -e gmp | grep ^LICENSE
# Expected: LICENSE="GPL-2.0-or-later"
```
If the LGPL-3.0 identifier still appears in the post-build manifest, the
recipe must be patched to set `LICENSE = "GPL-2.0-or-later"` explicitly
in a bbappend.

---

## 5. kbd-keymaps-pine — license applies to data files

**Issue:** The keyboard map files shipped by `kbd-keymaps-pine` are
distributed under GPL-3.0-or-later. Even though they are data (not
executable code), the GPL applies to their distribution.

**Mitigation options:**
- Drop `kbd-keymaps-pine` entirely if the target is headless.
- If Pine keyboard support is required: add `kbd:GPL-3.0-or-later` to
  `INCOMPATIBLE_LICENSE_EXCEPTIONS` and document this in your compliance
  artefacts.

---

## 6. `INCOMPATIBLE_LICENSE` does not cover nativesdk / build-host tools

**Issue:** `INCOMPATIBLE_LICENSE:class-target` only filters target-class
packages. Build-host and SDK tools (e.g. native `grep`, `coreutils-native`)
may still be GPLv3. These are not shipped in the product but may affect
SDK distribution compliance.

**Mitigation:** If distributing an SDK to customers, additionally set:
```bitbake
INCOMPATIBLE_LICENSE:class-nativesdk = "GPL-3.0* LGPL-3.0*"
```
And add appropriate nativesdk exceptions.

---

## 7. New dependencies introduced by recipe updates may re-introduce GPLv3

**Issue:** As layers are updated (e.g. AGL point releases), new package
dependencies may introduce GPLv3 packages that bypass the removal work.

**Mitigation:** Run `scripts/gplv3-scan.sh` as part of CI after every
layer update. The script exits non-zero if any `target_runtime` GPLv3
packages are found, making it suitable as a gate check.

---

## 8. `BAD_RECOMMENDATIONS` does not hard-fail

**Issue:** `BAD_RECOMMENDATIONS` prevents recommended-but-not-required
packages from being installed. If another package has a hard `RDEPENDS`
on `mc` or `screen`, they will still be installed.

**Mitigation:** After removing from `BAD_RECOMMENDATIONS`, verify with:
```sh
bitbake -g agl-image-minimal && grep '"mc"\|"screen"' pn-depends.dot
```
If hard deps exist, trace them and patch the upstream recipe or add a
bbappend removing the dependency.

---

## 9. connman-client not produced when readline is excluded *(RESOLVED in Phase 3)*

**Issue:** `packagegroup-agl-core-connectivity` has a hard `RDEPENDS` on
`connman-client`. When `readline` (GPL-3.0-or-later) is excluded via
`INCOMPATIBLE_LICENSE`, the connman `client` PACKAGECONFIG is disabled and
the `connman-client` RPM is never built. DNF fails during rootfs assembly
with "nothing provides connman-client".

**Resolution:**
- `meta-nogplv3/recipes-connectivity/connman/connman_%.bbappend` disables
  `PACKAGECONFIG[client]` to prevent build attempts against readline.
- `meta-nogplv3/recipes-platform/packagegroups/packagegroup-agl-core-connectivity.bbappend`
  removes `connman-client` from `RDEPENDS` so dependency resolution succeeds.

**Alternative:** Replace connman with NetworkManager (no readline dep) or
implement a readline-free connman client using libedit (BSD-2-Clause).

---

## 11. Demo image unbuildable — `parted` (GPL-3.0) blocks udisks2 dependency chain

**Issue:** `agl-ivi-demo-qt` and `agl-ivi-demo-control-panel` cannot be built
under `INCOMPATIBLE_LICENSE:class-target = "GPL-3.0*"` because `libblockdev`
has a hard `DEPENDS` on `parted`, which is GPL-3.0-or-later.

**Dependency chain:**
```
agl-ivi-demo-qt → packagegroup-agl-demo-platform → packagegroup-agl-demo
  → udisks2 → libblockdev → parted (GPL-3.0-or-later) ← BLOCKED
```

**Bitbake error:**
```
ERROR: Nothing PROVIDES 'parted'
    (libblockdev DEPENDS on or otherwise requires it)
ERROR: Required build target 'agl-ivi-demo-qt' has no buildable providers.
```

**Impact:** The demo UI layer (Qt IVI control panel, disk management via
udisks2) is not GPLv3-free. Projects requiring a strict GPLv3-free image
must stop at the `agl-ivi-image` tier.

**Mitigation options:**
1. Patch `libblockdev` to make `parted` an optional dep (`PACKAGECONFIG`).
2. Replace `parted` with a GPL-2.0 disk partitioning library (no drop-in exists
   in OpenEmbedded as of Scarthgap 5.0).
3. Remove `udisks2` from the demo packagegroup (loses automount/D-Bus storage).
4. **Selected baseline approach:** Use `agl-ivi-image` as the production target
   and document the demo UI layer as a GPLv3-encumbered optional component.

---

## 10. kbd-keymaps incorrectly excluded — caused systemd-vconsole-setup failure *(RESOLVED in Phase 3)*

**Issue:** Early config set `BAD_RECOMMENDATIONS += "... kbd kbd-keymaps ..."`.
`kbd-keymaps` license is `GPL-2.0-or-later` (NOT GPL-3.0). `systemd-vconsole-setup`
has a hard `RDEPENDS` on `kbd-keymaps`, so excluding it caused DNF to fail:
"nothing provides kbd-keymaps".

**Root cause:** Only `kbd-keymaps-pine` is GPL-3.0-or-later. The main `kbd`
package and `kbd-keymaps` are GPL-2.0-or-later.

**Resolution:** Updated `BAD_RECOMMENDATIONS` to exclude only `dosfstools` and
`kbd-keymaps-pine`. Corrected associated comment in `local.conf`.
