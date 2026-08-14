# Haiku platform stub for wifibox

PLATFORM_NAME="haiku"

modstat_platform() {
    echo "Kernel module management on Haiku is platform-specific. Implement modstat_platform in this file." >&2
    return 1
}

modload_platform() {
    echo "Module loading on Haiku is platform-specific. Implement modload_platform in this file." >&2
    return 1
}

modunload_platform() {
    echo "Module unloading on Haiku is platform-specific. Implement modunload_platform in this file." >&2
    return 1
}

devctl_platform() {
    echo "Device control and PPT management on Haiku must be implemented for your environment." >&2
    return 1
}

hypervisor_platform() {
    echo "Please implement hypervisor_platform in etc/platform/haiku.sh to launch your guest appliance (qemu or native hypervisor)." >&2
    return 1
}

hypervisor_ctl_platform() {
    echo "No hypervisor control implemented for Haiku in this stub." >&2
    return 1
}
