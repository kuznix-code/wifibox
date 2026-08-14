# OpenBSD platform stub for wifibox
# Provides conservative implementations for module and device operations.

PLATFORM_NAME="openbsd"

modstat_platform() {
    if command -v kldstat >/dev/null 2>&1; then
        kldstat "$@"
        return $?
    fi

    echo "kldstat not available on OpenBSD?" >&2
    return 1
}

modload_platform() {
    if command -v kldload >/dev/null 2>&1; then
        kldload "$@"
        return $?
    fi

    echo "kldload not available; please implement modload_platform for OpenBSD" >&2
    return 1
}

modunload_platform() {
    if command -v kldunload >/dev/null 2>&1; then
        kldunload "$@"
        return $?
    fi

    echo "kldunload not available; please implement modunload_platform for OpenBSD" >&2
    return 1
}

# Device control: OpenBSD does not have devctl; provide placeholder.
devctl_platform() {
    echo "devctl operations are host-specific on OpenBSD. Implement devctl_platform in this file to manage PPT devices." >&2
    return 1
}

# Hypervisor: OpenBSD uses vmd(8) for VMM -- provide a placeholder so integrators can
# replace it with a working command (for example, vmdctl or qemu) on their system.
hypervisor_platform() {
    echo "Please implement hypervisor_platform in etc/platform/openbsd.sh to launch your guest appliance (vmd/qemu/etc)." >&2
    return 1
}

hypervisor_ctl_platform() {
    echo "No hypervisor control implemented for OpenBSD in this stub. Implement hypervisor_ctl_platform if your hypervisor provides management commands." >&2
    return 1
}
