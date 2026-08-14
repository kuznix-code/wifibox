# NetBSD platform stub for wifibox

PLATFORM_NAME="netbsd"

modstat_platform() {
    if command -v kldstat >/dev/null 2>&1; then
        kldstat "$@"
        return $?
    fi

    echo "modstat not implemented for NetBSD in this stub" >&2
    return 1
}

modload_platform() {
    if command -v kldload >/dev/null 2>&1; then
        kldload "$@"
        return $?
    fi

    echo "modload not available; please implement modload_platform for NetBSD" >&2
    return 1
}

modunload_platform() {
    if command -v kldunload >/dev/null 2>&1; then
        kldunload "$@"
        return $?
    fi

    echo "modunload not available; please implement modunload_platform for NetBSD" >&2
    return 1
}

devctl_platform() {
    echo "NetBSD devctl operations are platform-specific. Implement devctl_platform in this file to manage device drivers or bindings." >&2
    return 1
}

hypervisor_platform() {
    echo "Please implement hypervisor_platform in etc/platform/netbsd.sh to launch your guest appliance (qemu, etc)." >&2
    return 1
}

hypervisor_ctl_platform() {
    echo "No hypervisor control implemented for NetBSD in this stub. Implement hypervisor_ctl_platform if available." >&2
    return 1
}
