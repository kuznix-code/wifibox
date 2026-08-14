# Managarm platform stub for wifibox

PLATFORM_NAME="managarm"

# Managarm is a research OS; integration will be highly platform-specific.
# Provide clear placeholders for integrators to implement.

modstat_platform() {
    echo "Managarm module management is platform-specific. Implement modstat_platform in this file." >&2
    return 1
}

modload_platform() {
    echo "Implement modload_platform to load kernel modules (if applicable) on Managarm." >&2
    return 1
}

modunload_platform() {
    echo "Implement modunload_platform to unload modules on Managarm." >&2
    return 1
}

devctl_platform() {
    echo "Device control on Managarm is platform-specific. Implement devctl_platform in this file." >&2
    return 1
}

hypervisor_platform() {
    echo "Please implement hypervisor_platform in etc/platform/managarm.sh to launch your guest appliance." >&2
    return 1
}

hypervisor_ctl_platform() {
    echo "No hypervisor control implemented for Managarm in this stub." >&2
    return 1
}
