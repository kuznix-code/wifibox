# Wifibox

Wifibox deploys a small guest operating system to drive a wireless networking card on the host using PCI pass-through. The guest runs the wireless stack and exposes network connectivity to the host, letting you use a guest-supported driver for a host device that otherwise performs poorly.

This repository contains the host-side scripts, configuration templates and helper files to manage the guest appliance and the device pass-through.

Highlights

- Runs a lightweight guest appliance to control a PCI wireless card via PCI pass-through; keeps host resource usage low.
- Configuration files can be shared with the host; for example the guest may use wpa_supplicant or hostapd and it is possible to import host configuration files without changes.
- Control sockets for wpa_supplicant/hostapd can be exposed and forwarded so host utilities may control the guest service.
- Everything required to run the host-side service is provided in this repository. Guest disk images are not included and must be installed separately.

Warning

This is an experimental project without guarantees or warranties. Use it at your own risk. Wifibox is a workaround for hosts that do not have satisfactory wireless driver support; it is not intended to be a permanent replacement for a native host networking stack.

Prerequisites

Before installation, verify these requirements on the target computer:

- A CPU and platform that support PCI pass-through (IOMMU). Sufficient memory (guest memory depends on the appliance, typically ~256 MB or more) and disk space for the guest image are required.
- A PCI wireless card that is supported by the guest kernel (usually a recent Linux kernel image). The driver in the guest should support Message Signaled Interrupts (MSI) if your host hypervisor requires it for pass-through. USB wireless adapters are not supported.
- Host virtualization components that support PCI pass-through on your platform. Wifibox is host-implementation-agnostic; the exact hypervisor or kernel module to use depends on the host operating system (see Compatibility below). You must provide a working mechanism to launch the guest and bind/unbind the device for pass-through.

Guest image layout

The guest appliance files are not included in this repository and should be provided separately. The expected layout is:

- esp.img: EFI System Partition (ESP) containing the guest kernel or bootloader and supporting files (FAT file system for EFI-based boots).
- root.img: Root file system image used as the guest's secondary disk.

Installation (manual)

A Makefile is provided for manual installation (recommended for development and testing):

make install \
    PREFIX=<prefix> \
    LOCALBASE=<local prefix> \
    GUEST_ROOT=<guest disk images location> \
    GUEST_MAN=<guest manual page location> \
    RECOVERY_METHOD=<method to use on suspend and resume>

Default PREFIX is /usr/local. LOCALBASE can be used to point to alternate locations for utilities used by the install workflow.

RECOVERY_METHOD can be used to configure how Wifibox behaves around suspend/resume events; possible values provided by the Makefile are: restart_vmm, suspend_guest, suspend_vmm or empty (disabled).

Documentation

A manual page is included; install it via the Makefile and inspect using your platform's man(1) tooling after installation.

Compatibility

This project aims to support a variety of non-Linux and non-FreeBSD host operating systems and targets. The goal is to support systems where the host kernel or hypervisor allows PCI pass-through and can run a guest appliance to control a device.

Notable host operating systems targeted for support (examples):

- OpenBSD
- NetBSD
- Haiku
- Managarm
- Other Unix-like or microkernel-based systems that provide PCI pass-through or a comparable device isolation mechanism

Target guest architectures and triplets

- The guest appliance images are expected to be built for "*-elf" targets (for example x86_64-elf, aarch64-elf or other bare-metal EFI-targeted images) in environments where Linux or FreeBSD target images are not appropriate.
- Explicitly excluded targets: linux-* and freebsd-* (this project focuses on non-Linux and non-FreeBSD embedded guest targets and host-side integrations where that fits the workflow).

Implementation notes

- This repository provides host-side scripts and configuration templates. Because host APIs and commands differ between operating systems (module management, device binding, hypervisor invocation), the implementation must be adapted per-host. See the etc/ and rc.d/ (or equivalent) directories for configuration templates.
- Contributions adding platform-specific support (scripts, packaging, and documentation) for OpenBSD, NetBSD, Haiku, Managarm, and other platforms are welcome. Please provide clear instructions for how the host-side pieces should be installed and any required kernel modules, device bindings or hypervisor tooling.

Compatibility table

This section formerly contained a list of host-specific FreeBSD configurations. That FreeBSD-specific content has been removed. Please open an issue or submit a pull request with your host, CPU, wireless NIC and working host version if you have a configuration to add.

Contributing

If you add support for a new host platform or a new target triplet, please:

- Add a short platform-specific README or instructions in etc/ or a new directory under contrib/.
- Add any platform-specific scripts to sbin/ and corresponding service unit files or rc scripts in the appropriate place (rc.d/ is a template for some systems).
- Update this README with a short entry describing how that platform integrates with Wifibox.

License

This project is licensed under the terms contained in the LICENSE file in this repository.
