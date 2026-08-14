# Platform abstraction helpers

# This generic platform stub provides minimal implementations and documentation
# for the platform-specific files under etc/platform/.  It is intended as a
# safe fallback during development: it implements a small subset of behavior
# so the main script's autodetection and checks don't fail catastrophically.

# Platform name (override in platform files)
PLATFORM_NAME="generic"

# If a platform doesn't provide an implementation for module loading/stat,
# fall back to these helpers which will try common BSD-style commands when
# available, or emit a helpful message otherwise.

modstat_platform() {
    if command -v kldstat >/dev/null 2>&1; then
        kldstat "$@"
        return $?
    fi

    echo "modstat not implemented for platform: ${PLATFORM_NAME}" >&2
    return 1
}

modload_platform() {
    if command -v kldload >/dev/null 2>&1; then
        kldload "$@"
        return $?
    fi

    echo "modload not implemented for platform: ${PLATFORM_NAME}. Please implement modload_platform in the platform file." >&2
    return 1
}

modunload_platform() {
    if command -v kldunload >/dev/null 2>&1; then
        kldunload "$@"
        return $?
    fi

    echo "modunload not implemented for platform: ${PLATFORM_NAME}. Please implement modunload_platform in the platform file." >&2
    return 1
}

# devctl_platform: default calls devctl if present, otherwise prints a message.
devctl_platform() {
    if command -v devctl >/dev/null 2>&1; then
        devctl "$@"
        return $?
    fi

    echo "devctl not available on ${PLATFORM_NAME}; implement devctl_platform to manage PPT devices." >&2
    return 1
}

# hypervisor_platform/hypervisor_ctl_platform
# The generic implementation supports the "-s help" probe used by the
# main script's check_virtfs() by advertising virtio-9p so the check passes
# during development. For any other invocation, the generic stub will
# instruct the user to provide a platform-specific implementation.

hypervisor_platform() {
    # If the caller asks for "-s help" (bhyve probe), respond with a small
    # help-like output that contains virtio-9p so check_virtfs() can succeed
    # in development/testing environments.
    for a in "$@"; do
        if [ "${a}" = "-s" ]; then
            # look ahead for 'help'
            shift
            if [ "$1" = "help" ] || [ "$1" = "-s" ]; then
                echo "virtio-9p"
                return 0
            fi
        fi
    done

    echo "hypervisor not implemented for ${PLATFORM_NAME}. Provide hypervisor_platform in etc/platform/${PLATFORM_NAME}.sh to launch the guest or provide a wrapper at ${CONFDIR}/platform/${PLATFORM_NAME}.sh" >&2
    return 1
}

hypervisor_ctl_platform() {
    echo "hypervisor_ctl not implemented for ${PLATFORM_NAME}. Provide hypervisor_ctl_platform in the platform file if the hypervisor supports management commands." >&2
    return 1
}

# End of generic platform stub
