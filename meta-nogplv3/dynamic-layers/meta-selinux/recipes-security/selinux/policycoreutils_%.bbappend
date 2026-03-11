# GPLv3 removal baseline: remove GPL-3.0 packages from policycoreutils subpackages
# policycoreutils-fixfiles uses grep (GPL-3.0-only) and findutils (GPL-3.0-or-later)
# at runtime; busybox provides equivalent /usr/bin/find and /bin/grep functionality.
# NOTE: fixfiles functionality may be degraded without GNU grep/find extensions.
RDEPENDS:${PN}-fixfiles:remove = "grep findutils"
