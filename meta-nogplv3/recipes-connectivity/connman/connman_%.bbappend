# GPLv3 removal baseline: remove connman-client (GPL-3.0 via readline dep)
# readline (GPL-3.0-or-later) is required by the connman interactive client.
# The connman D-Bus API is still available; use connmanctl alternatives
# or libedit/editline (BSD) for a readline-free interactive client.
PACKAGECONFIG:remove = "client"
