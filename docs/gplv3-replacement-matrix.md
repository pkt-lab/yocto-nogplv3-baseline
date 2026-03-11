# GPLv3 Package Replacement Matrix

Tested on: AGL Terrific Trout 19.92.0 / Yocto Scarthgap 5.0 / qemuarm64

| GPLv3 Package | Version | License | Replacement | Compatibility Risk | Notes |
|---|---|---|---|---|---|
| `coreutils` | 9.4 | GPL-3.0-or-later | busybox | Medium | GNU-specific flags (--sort=version, etc.) break. Core ops (ls/cp/mv) work fine. |
| `findutils` | 4.9.0 | GPL-3.0-or-later | busybox find | Low-Medium | `-printf` not supported in busybox find. `-exec +` works. |
| `grep` | 3.11 | GPL-3.0-only | busybox grep | Low | Most POSIX grep usage works. Some GNU-specific regex extensions differ. |
| `readline` | 8.2 | GPL-3.0-or-later | libedit (BSD) | Medium | libedit API is similar but not identical. Packages must be configured with `--with-libedit`. |
| `mc` | 4.8.31 | GPL-3.0-only | Remove | None | Midnight Commander is non-essential in embedded minimal images. |
| `screen` | 4.9.1 | GPL-3.0-or-later | Remove | None | Not needed in minimal image. tmux (MIT) if session management required. |
| `kbd` | 2.6.4 | GPL-3.0-or-later | Exception or remove | Low | Headless targets can drop kbd entirely. If keyboard needed, add exception. |
| `libgcc` | (gcc) | GPL-3.0-with-GCC-exception | Exception (GCC RLE) | None | GCC Runtime Library Exception allows distribution. Always except this. |
| `libstdc++` | (gcc) | GPL-3.0-with-GCC-exception | Exception (GCC RLE) | None | Same as libgcc. Always except this. |
| `gmp` | 6.3.0 | GPL-2.0-or-later \| LGPL-3.0-or-later | Elect GPL-2.0 side | None | Dual license. Exception to elect GPLv2 side. No code changes needed. |
| `libidn2` | 2.3.7 | (GPL-2.0-or-later \| LGPL-3.0-only) & Unicode-DFS-2016 | Elect GPL-2.0 side | None | Dual license. Exception to elect GPLv2 side. |
| `libunistring` | 1.2 | LGPL-3.0-or-later \| GPL-2.0-or-later | Elect GPL-2.0 side | None | Dual license. Exception to elect GPLv2 side. |
| `nettle` | 3.9.1 | LGPL-3.0-or-later \| GPL-2.0-or-later | Elect GPL-2.0 side | None | Dual license. Exception to elect GPLv2 side. |

---

## Validation Steps Per Replacement

### coreutils → busybox
1. Confirm `VIRTUAL-RUNTIME_base-utils = "busybox"` in local.conf
2. Check that no recipe has hard `RDEPENDS_xxx += "coreutils"`
3. After rebuild: boot QEMU, run `ls -la /`, `cp`, `mv` — verify basic ops work
4. Run `which ls` — should point to busybox symlink

### findutils → busybox find
1. After rebuild: test `find / -name "*.conf" -type f`
2. If any script uses `-printf` → rewrite or keep findutils with exception

### grep → busybox grep
1. After rebuild: `grep -r "pattern" /etc/` — basic usage
2. Check for scripts using `-P` (PCRE) — busybox grep has no `-P`

### readline removal / libedit
1. Identify what depends on readline: `bitbake -g <image> && grep readline task-depends.dot`
2. Each dependent package needs `--with-libedit` configure flag via `.bbappend`

### mc, screen removal
1. Add to `IMAGE_INSTALL:remove` or `BAD_RECOMMENDATIONS`
2. Rebuild — no compatibility concern

---

## Risk Legend

| Level | Meaning |
|---|---|
| None | Drop-in safe |
| Low | Minor behavior differences, unlikely to affect production |
| Medium | Known gaps, requires testing against your use case |
| High | Significant feature gaps, probably requires exceptions |
