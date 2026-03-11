#!/bin/bash
# gplv3-scan.sh — Scan a Yocto build dir for GPLv3 target packages
#
# Usage: ./gplv3-scan.sh <build_dir> [output_file]
#
# Output: sorted unique list of packages with GPL-3.0/LGPL-3.0/AGPL-3.0 licenses
# found in target image license manifests.

set -e

BUILD_DIR="${1:-$(pwd)}"
OUTPUT="${2:-gplv3-report.txt}"

if [ ! -d "$BUILD_DIR/tmp/deploy/licenses" ]; then
    echo "ERROR: $BUILD_DIR does not look like a Yocto build dir (tmp/deploy/licenses not found)"
    exit 1
fi

echo "Scanning: $BUILD_DIR"
echo "Output:   $OUTPUT"
echo ""

TMPFILE=$(mktemp)

# Find all license.manifest files under target machine directories
# (skip native/ and allarch/ which are host tools)
find "$BUILD_DIR/tmp/deploy/licenses" \
    -name "license.manifest" \
    -not -path "*/native/*" \
    -not -path "*/allarch/*" \
    | while read -r manifest; do
        # Parse each manifest: group PACKAGE NAME + LICENSE
        python3 - "$manifest" << 'PYEOF'
import re, sys

with open(sys.argv[1]) as f:
    content = f.read()

entries = re.split(r'\n(?=PACKAGE NAME:)', content.strip())
for entry in entries:
    lines = {}
    for line in entry.strip().splitlines():
        if ': ' in line:
            k, v = line.split(': ', 1)
            lines[k] = v
    lic = lines.get('LICENSE', '')
    if re.search(r'GPL-3\.0|LGPL-3\.0|AGPL-3\.0', lic):
        pkg = lines.get('PACKAGE NAME', '?')
        recipe = lines.get('RECIPE NAME', '?')
        ver = lines.get('PACKAGE VERSION', '?')
        print(f"{pkg}\t{recipe}\t{ver}\t{lic}")
PYEOF
    done | sort -u > "$TMPFILE"

COUNT=$(wc -l < "$TMPFILE")

if [ "$COUNT" -eq 0 ]; then
    echo "CLEAN: No GPLv3 target packages found."
    echo "CLEAN" > "$OUTPUT"
    rm -f "$TMPFILE"
    exit 0
fi

echo "Found $COUNT GPLv3-touched package entries:"
echo ""
printf "%-40s %-25s %-10s %s\n" "PACKAGE" "RECIPE" "VERSION" "LICENSE"
printf "%-40s %-25s %-10s %s\n" "-------" "------" "-------" "-------"
while IFS=$'\t' read -r pkg recipe ver lic; do
    printf "%-40s %-25s %-10s %s\n" "$pkg" "$recipe" "$ver" "$lic"
done < "$TMPFILE"

echo ""
echo "Writing report to: $OUTPUT"
{
    echo "# GPLv3 Scan Report"
    echo "# Build dir: $BUILD_DIR"
    echo "# Date: $(date)"
    echo "# Total: $COUNT packages"
    echo ""
    printf "%-40s %-25s %-10s %s\n" "PACKAGE" "RECIPE" "VERSION" "LICENSE"
    cat "$TMPFILE"
} > "$OUTPUT"

rm -f "$TMPFILE"
echo "Done."
