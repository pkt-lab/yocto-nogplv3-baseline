# GPLv3 removal baseline: have busybox RPROVIDE GPL-3.0 package names
# busybox (GPL-2.0-only) provides functionally equivalent implementations
# of these GPL-3.0+ tools:
#   coreutils  - GPL-3.0-or-later  -> busybox provides ls, cp, mv, chmod, etc.
#   findutils  - GPL-3.0-or-later  -> busybox provides find, xargs
#   grep       - GPL-3.0-only      -> busybox provides grep, egrep, fgrep
#   tar        - GPL-3.0-only      -> busybox provides tar
#   readline   - GPL-3.0-or-later  -> editline/libedit is BSD alternative
# NOTE: busybox implementations may lack some GNU extensions. Test thoroughly.
RPROVIDES:${PN} += "coreutils findutils grep tar"
RREPLACES:${PN} += "coreutils findutils grep tar"
RCONFLICTS:${PN} += "coreutils findutils grep tar"
