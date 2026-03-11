# GPLv3 removal baseline: remove GPLv3-licensed packages from core debug tools
# gdb (GPL-2.0-only & GPL-3.0-only) and gdbserver are excluded
# Alternative: use LLDB from meta-clang (Apache-2.0)
RDEPENDS:packagegroup-core-tools-debug:remove = "gdb gdbserver"
