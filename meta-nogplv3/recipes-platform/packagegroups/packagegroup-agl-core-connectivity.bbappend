# GPLv3 removal baseline: connman-client requires readline (GPL-3.0-or-later)
# connman_%.bbappend disables PACKAGECONFIG[client], so connman-client binary
# is not compiled and the connman-client RPM is never produced.
# Remove it from the hard RDEPENDS of this packagegroup so rootfs assembly
# does not fail when readline is excluded via INCOMPATIBLE_LICENSE.
RDEPENDS:${PN}:remove = "connman-client"
