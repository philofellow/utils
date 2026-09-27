#!/bin/bash
set -euo pipefail

SOURCE="/home/philofellow/usb1/"
DEST="/mnt/usb1/"
EXPECTED_UUID="64A5-F009"
LOG="/home/philofellow/workspace/utils/usb1-backup.log"

exec >> "$LOG" 2>&1

echo
echo "========================================"
echo "Backup started: $(date)"
echo "========================================"

# Make sure USB is actually mounted.
if ! mountpoint -q "$DEST"; then
    echo "ERROR: $DEST is not mounted."
    echo "Backup aborted."
    exit 1
fi

# Verify that the correct USB drive is mounted.
ACTUAL_UUID=$(findmnt -n -o UUID --target "$DEST" | head -n1)

if [ "$ACTUAL_UUID" != "$EXPECTED_UUID" ]; then
    echo "ERROR: Wrong filesystem mounted at $DEST"
    echo "Expected UUID: $EXPECTED_UUID"
    echo "Actual UUID:   $ACTUAL_UUID"
    echo "Backup aborted."
    exit 1
fi

echo "USB verified."

# Mirror primary storage to USB.
rsync -rt \
    --delete \
    --modify-window=1 \
    --omit-dir-times \
    --stats \
    "$SOURCE" "$DEST"

echo "Backup completed successfully: $(date)"
