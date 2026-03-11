# GPLv3 removal baseline: remove gdbm (GPL-3.0-only) from python3 build
# python3-gdbm and python3-dbm modules will not be built.
# Use python3-sqlite3 or python3-shelve (via sqlite3 backend) as alternatives.
PACKAGECONFIG:remove = "gdbm"
