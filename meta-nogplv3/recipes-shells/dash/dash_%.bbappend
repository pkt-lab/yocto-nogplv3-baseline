# GPLv3 removal baseline: have dash provide bash (GPL-3.0-or-later replacement)
# dash (BSD-3-Clause) provides POSIX sh compatibility.
# NOTE: dash is not 100% bash-compatible (no arrays, no bash-specific features).
#       All post-install scriptlets and shell scripts must be POSIX sh compatible.
RPROVIDES:${PN} += "bash virtual/bash"
RREPLACES:${PN} += "bash"
RCONFLICTS:${PN} += "bash"

# Create /bin/bash symlink so scripts with #!/bin/bash shebangs work
do_install:append() {
    if [ ! -e "${D}${base_bindir}/bash" ]; then
        ln -sf dash ${D}${base_bindir}/bash
    fi
}

# Include the bash symlink in the package
FILES:${PN} += "${base_bindir}/bash"

# Satisfy QA file-rdeps checks for /bin/bash
PACKAGES_DYNAMIC += "bash"
# Make our package satisfy RDEPENDS on bash
RPROVIDES:${PN} += "/bin/bash"
