#!/bin/sh
# Simple example helper that prints recommended VFIO bind/unbind commands for Linux.
# This script is non-destructive by default: it only prints the commands.
# To apply the commands pass --apply.

APPLY=NO
if [ "${1}" = "--apply" ]; then
    APPLY=YES
    shift
fi

usage() {
    cat <<EOF
Usage: $0 [--apply] <pci-id>
Example PCI IDs: 0000:01:00.0

This helper shows the steps to bind a PCI device to vfio-pci for passthrough
on Linux. When run with --apply it will attempt to perform the operations.
EOF
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

PCI_ID="$1"

echo "Detected PCI device: ${PCI_ID}"

echo "Commands to bind ${PCI_ID} to vfio-pci (print-only):"

echo "  # Unbind from current driver"
echo "  echo -n '${PCI_ID}' > /sys/bus/pci/devices/${PCI_ID}/driver/unbind"

echo "  # Bind to vfio-pci (requires vfio-pci loaded and IOMMU enabled)"
echo "  echo 'vfio-pci' > /sys/bus/pci/devices/${PCI_ID}/driver_override"
echo "  echo -n '${PCI_ID}' > /sys/bus/pci/drivers_probe"

if [ "${APPLY}" = "YES" ]; then
    echo "Applying steps..."
    set -e
    if [ ! -d /sys/bus/pci/devices/${PCI_ID} ]; then
        echo "Device ${PCI_ID} not found in sysfs" >&2
        exit 1
    fi
    if [ -d /sys/bus/pci/devices/${PCI_ID}/driver ]; then
        echo -n "${PCI_ID}" > /sys/bus/pci/devices/${PCI_ID}/driver/unbind || true
    fi
    echo vfio-pci > /sys/bus/pci/devices/${PCI_ID}/driver_override || true
    # Trigger driver probe for the device
    echo -n "${PCI_ID}" > /sys/bus/pci/drivers_probe || true
    echo "Done (attempted). Check dmesg and ls -l /sys/bus/pci/devices/${PCI_ID}"
fi
