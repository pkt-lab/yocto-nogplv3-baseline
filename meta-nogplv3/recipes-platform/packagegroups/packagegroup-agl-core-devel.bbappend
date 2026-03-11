# GPLv3 removal baseline: remove GPLv3-licensed packages from devel packagegroup
# Packages excluded due to INCOMPATIBLE_LICENSE = "GPL-3.0* LGPL-3.0* AGPL-3.0*":
#   screen  - GPL-3.0-or-later
#   rsync   - GPL-3.0-or-later
#   gdb     - GPL-2.0-only & GPL-3.0-only & LGPL-2.0-only & LGPL-3.0-only
#   less    - GPL-3.0-or-later | BSD-2-Clause (dual-license; conservative removal)
#   mc      - GPL-3.0-only (if present)
RDEPENDS:packagegroup-agl-core-devel:remove = "screen rsync gdb less mc"
