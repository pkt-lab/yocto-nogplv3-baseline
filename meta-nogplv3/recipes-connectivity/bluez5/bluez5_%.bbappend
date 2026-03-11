# GPLv3 removal baseline: remove readline (GPL-3.0-or-later) from bluez5
# The readline PACKAGECONFIG enables bluetoothctl interactive client.
# Alternative: use a readline-free client or libedit (BSD) instead.
PACKAGECONFIG:remove = "readline"
