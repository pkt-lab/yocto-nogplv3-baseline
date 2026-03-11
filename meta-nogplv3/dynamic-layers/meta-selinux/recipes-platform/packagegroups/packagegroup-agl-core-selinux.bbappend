# GPLv3 removal baseline: remove packages with GPL-3.0 transitive deps
# - selinux-python-audit2allow requires binutils (GPL-3.0-only)
# - policycoreutils-hll pulls in selinux-python → selinux-python-sepolicy → binutils
# - selinux-python (full package) pulls in selinux-python-sepolicy → binutils
# Alternative: build binutils with AGPL-3.0 exception or use llvm-ar equivalents
RDEPENDS:packagegroup-agl-core-selinux-devel:remove = "selinux-python-audit2allow policycoreutils-hll"
