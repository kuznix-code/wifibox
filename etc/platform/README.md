# Platform files README

This directory holds platform-specific stubs that the wifibox host script
(sbin/wifibox) can source to implement host-specific behaviors.

Each platform file is a POSIX shell script that may (and typically should)
set the following symbol and provide the following functions when
applicable:

Variables
- PLATFORM_NAME: a short identifier for the platform (e.g. "openbsd", "linux").
- BOOTROM (optional): path to a platform-specific UEFI/boot ROM file used by the hypervisor.

Functions (recommended names)
- modstat_platform <args>
    Report kernel module status. Fallback is provided by the generic stub.

- modload_platform <module>
    Load a kernel module or equivalent. Called via modload() wrapper in sbin/wifibox.

- modunload_platform <module>
    Unload a kernel module. Called via modunload() wrapper.

- devctl_platform <args>
    Manage pass-through device bindings (attach/detach drivers, set driver). The sbin/wifibox script calls devctl_cmd wrapper which delegates here when present.

- hypervisor_platform <args>
    Launch the hypervisor with provided arguments. This should accept the arguments built by the main script and start the guest. For example, on Linux this might call qemu-system-x86_64, on other systems it might call a native hypervisor or a wrapper script.

- hypervisor_ctl_platform <args>
    Optional: control/management operations for the hypervisor (destroy/force-poweroff). If not provided, sbin/wifibox will fall back to generic behavior or return an error.

Notes
- The main script will try to source a platform file in this order:
  1) ${CONFDIR}/platform/${PLATFORM}.sh
  2) ./etc/platform/${PLATFORM}.sh (development fallback)
  3) ./etc/platform/generic.sh

- Platform files MUST be idempotent and safe to source. They should not perform destructive actions during sourcing; only define functions and variables.

- If you add a concrete platform implementation, document exact host requirements (kernel modules, packages, and distro/version specific notes) in a separate README or under contrib/<platform>/.
