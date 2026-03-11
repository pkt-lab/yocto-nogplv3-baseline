# GPLv3 removal baseline: remove gdbm (GPL-3.0-only) from perl build
# perl-module-gdbm will not be built.
PACKAGECONFIG:remove = "gdbm"
