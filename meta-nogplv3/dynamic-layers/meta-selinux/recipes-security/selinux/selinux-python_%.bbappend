# GPLv3 removal baseline: remove binutils (GPL-3.0-only) from selinux-python-sepolicy
# selinux-python-sepolicy uses binutils to analyze policy binary object files.
# This removes the capability to use sepolicy's binary analysis features.
# Alternative: use policy analysis tools that don't depend on binutils.
RDEPENDS:${PN}-sepolicy:remove = "binutils"
