# Linux testing platform stub for wifibox
# This is intended for testing only. It uses qemu-system-x86_64 by default
# to boot EFI images (OVMF) and exposes a simple way to run the guest appliance.
# It intentionally does not attempt to bind/unbind real devices automatically.

PLATFORM_NAME="linux"

# Default hypervisor command (can be overridden by setting QEMU_CMD)
QEMU_CMD=${QEMU_CMD:-qemu-system-x86_64}
OVMF_CODE=${OVMF_CODE:-/usr/share/OVMF/OVMF_CODE.fd}
OVMF_VARS=${OVMF_VARS:-/usr/share/OVMF/OVMF_VARS.fd}

hypervisor_platform() {
    # Simple qemu invocation for testing; this forwards a tap interface and
    # attaches the two disk images as virtio-blk devices. For real device
    # passthrough you must use VFIO and bind the device to vfio-pci on the host.
    # Usage: hypervisor_platform [qemu-args...]

    ${QEMU_CMD} "$@"
}

hypervisor_ctl_platform() {
    echo "No management interface implemented for the qemu testing backend. Use QEMU monitor or kill the process." >&2
    return 1
}

modstat_platform() {
    echo "Module management on Linux is distro-specific. Use lsmod/modinfo if needed." >&2
    command -v lsmod >/dev/null 2>&1 || return 1
    lsmod | grep -i "vhost\|vfio\|tun\|tap" || true
}

modload_platform() {
    echo "To load kernel modules on Linux use modprobe. This stub will attempt modprobe if available." >&2
    if command -v modprobe >/dev/null 2>&1; then
        modprobe "$@"
        return $?
    fi
    return 1
}

modunload_platform() {
    echo "To unload kernel modules on Linux use modprobe -r. This stub will attempt modprobe -r if available." >&2
    if command -v modprobe >/dev/null 2>&1; then
        modprobe -r "$@"
        return $?
    fi
    return 1
}

devctl_platform() {
    echo "Device control on Linux should be done via sysfs (bind/unbind drivers) or using vfio-bind helpers. See etc/platform/linux/vfio-helper.sh for examples." >&2
    return 1
}
