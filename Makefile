# Simple GNU-make compatible Makefile for wifibox
# Converted from BSD make syntax to be compatible with GNU make.

PREFIX ?= /usr/local
LOCALBASE ?= /usr/local
GUEST_ROOT ?= $(LOCALBASE)/share/wifibox
RECOVERY_METHOD ?= restart_vmm

BINDIR = $(DESTDIR)$(PREFIX)/sbin
ETCDIR = $(DESTDIR)$(PREFIX)/etc
RCDIR = $(ETCDIR)/rc.d
SHAREDIR = $(DESTDIR)$(PREFIX)/share
MANDIR = $(SHAREDIR)/man

MKDIR = /bin/mkdir
LN = /bin/ln
SED = /usr/bin/sed
CP = /bin/cp
CHMOD = /bin/chmod
GZIP = /usr/bin/gzip
GIT = $(LOCALBASE)/bin/git
SHELLCHECK = $(LOCALBASE)/bin/shellcheck
UNAME = /usr/bin/uname
IGOR = $(LOCALBASE)/bin/igor
ASPELL = $(LOCALBASE)/bin/aspell
MANDOC = /usr/bin/mandoc
ECHO = /bin/echo
TOUCH = /usr/bin/touch
RM = /bin/rm -f

# Compute VERSION via git if available
ifneq ($(shell test -x $(GIT) && echo yes),)
VERSION := $(shell $(GIT) describe --tags --always 2>/dev/null || echo unknown)
else
VERSION := unknown
endif

# Guest manual page
ifdef GUEST_MAN
_GUEST_MAN := $(GUEST_MAN)
else
_GUEST_MAN := ../man8/wifibox.8.gz
endif

# Default target does nothing to avoid accidental install on 'make'
.PHONY: all
all:
	@echo "No default build. Use 'make install' to install or 'make shellcheck' to lint."

SUB_LIST := PREFIX=$(PREFIX) LOCALBASE=$(LOCALBASE) VERSION=$(VERSION) GUEST_ROOT=$(GUEST_ROOT)

# Recovery method mapping - build sed-friendly shell substitutions inside install recipe

SCRIPT_SRC := sbin/wifibox
MAN_SRC := man/wifibox.8

.PHONY: install
install:
	$(MKDIR) -p $(BINDIR)
	@_subs=""; \
	_subs="$${_subs} -e s!%%PREFIX%%!$(PREFIX)!g"; \
	_subs="$${_subs} -e s!%%LOCALBASE%%!$(LOCALBASE)!g"; \
	_subs="$${_subs} -e s!%%VERSION%%!$(VERSION)!g"; \
	_subs="$${_subs} -e s!%%GUEST_ROOT%%!$(GUEST_ROOT)!g"; \
	# Add recovery method commands
	if [ "$(RECOVERY_METHOD)" = "restart_vmm" ]; then \
		_subs="$${_subs} -e s!%%SUSPEND_CMD%%!/usr/bin/true!g -e s!%%RESUME_CMD%%!$${command} restart vmm!g"; \
	elif [ "$(RECOVERY_METHOD)" = "suspend_guest" ]; then \
		_subs="$${_subs} -e s!%%SUSPEND_CMD%%!$${command} stop guest!g -e s!%%RESUME_CMD%%!$${command} start guest!g"; \
	elif [ "$(RECOVERY_METHOD)" = "suspend_vmm" ]; then \
		_subs="$${_subs} -e s!%%SUSPEND_CMD%%!$${command} stop vmm!g -e s!%%RESUME_CMD%%!$${command} start vmm!g"; \
	else \
		_subs="$${_subs} -e s!%%SUSPEND_CMD%%!/usr/bin/true!g -e s!%%RESUME_CMD%%!/usr/bin/true!g"; \
	fi; \
	$(SED) $${_subs} $(SCRIPT_SRC) > $(BINDIR)/wifibox; \
	$(CHMOD) 555 $(BINDIR)/wifibox

	$(MKDIR) -p $(ETCDIR)/wifibox
	$(CP) -R etc/* $(ETCDIR)/wifibox/ || true
	# Install platform-specific stubs (if present)
	$(MKDIR) -p $(ETCDIR)/wifibox/platform
	@if [ -d etc/platform ]; then \
		$(CP) -R etc/platform/* $(ETCDIR)/wifibox/platform/ || true; \
	fi

	$(MKDIR) -p $(RCDIR)
	@_subs=""; \
	_subs="$${_subs} -e s!%%PREFIX%%!$(PREFIX)!g -e s!%%LOCALBASE%%!$(LOCALBASE)!g -e s!%%VERSION%%!$(VERSION)!g -e s!%%GUEST_ROOT%%!$(GUEST_ROOT)!g"; \
	$(SED) $${_subs} rc.d/wifibox > $(RCDIR)/wifibox; \
	$(CHMOD) 555 $(RCDIR)/wifibox

	$(MKDIR) -p $(MANDIR)/man8
	@_subs=""; \
	_subs="$${_subs} -e s!%%PREFIX%%!$(PREFIX)!g -e s!%%LOCALBASE%%!$(LOCALBASE)!g -e s!%%VERSION%%!$(VERSION)!g -e s!%%GUEST_ROOT%%!$(GUEST_ROOT)!g"; \
	$(SED) $${_subs} $(MAN_SRC) | $(GZIP) -c > $(MANDIR)/man8/wifibox.8.gz
	$(LN) -s $(_GUEST_MAN) $(MANDIR)/man5/wifibox-guest.5.gz || true

.PHONY: clean
clean:
	@# no-op

.PHONY: shellcheck
shellcheck:
	@$(SHELLCHECK) -x $(SCRIPT_SRC) || true

.PHONY: mancheck
mancheck:
	@$(ECHO) mandoc -T lint
	# Create a dummy manual page to suppress the `mandoc` warning
	@$(TOUCH) wifibox-guest.5
	@_subs=""; \
	_subs="$${_subs} -e s!%%PREFIX%%!$(PREFIX)!g -e s!%%LOCALBASE%%!$(LOCALBASE)!g -e s!%%VERSION%%!$(VERSION)!g -e s!%%GUEST_ROOT%%!$(GUEST_ROOT)!g"; \
	$(SED) $${_subs} $(MAN_SRC) | $(MANDOC) -T lint || true
	@$(RM) wifibox-guest.5
	@$(ECHO) igor
	@$(SED) $${_subs} $(MAN_SRC) | $(IGOR) || true
