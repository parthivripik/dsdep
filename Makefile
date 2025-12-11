# =============================================================================
# dsdep - Data Science Deployment Tool
# Makefile for building and installing
# =============================================================================

PACKAGE_NAME = dsdep
VERSION = 1.0.0
PREFIX ?= /usr/local
DESTDIR ?=
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/$(PACKAGE_NAME)
DOCDIR = $(PREFIX)/share/doc/$(PACKAGE_NAME)
MANDIR = $(PREFIX)/share/man/man1

.PHONY: all install uninstall clean deb rpm test help local-install

all: help

help:
	@echo "dsdep - Data Science Deployment Tool"
	@echo ""
	@echo "Available targets:"
	@echo "  make install        - Install to system (requires sudo)"
	@echo "  make local-install  - Install to ~/.local/bin (no sudo)"
	@echo "  make uninstall      - Remove from system"
	@echo "  make deb            - Build Debian package (.deb)"
	@echo "  make rpm            - Build RPM package (requires alien)"
	@echo "  make test           - Run syntax check"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "After installation, run 'dsdep --help' for usage."

# System-wide installation (requires sudo)
install:
	@echo "Installing $(PACKAGE_NAME) v$(VERSION)..."
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(SHAREDIR)/templates
	install -d $(DESTDIR)$(DOCDIR)
	install -m 0755 bin/dsdep $(DESTDIR)$(BINDIR)/dsdep
	install -m 0644 templates/requirements.txt $(DESTDIR)$(SHAREDIR)/templates/
	install -m 0644 README.md $(DESTDIR)$(DOCDIR)/
	@echo ""
	@echo "Installation complete!"
	@echo "Run 'dsdep --help' to get started."

# Local user installation (no sudo required)
local-install:
	@echo "Installing $(PACKAGE_NAME) v$(VERSION) to ~/.local/bin..."
	@mkdir -p ~/.local/bin
	@mkdir -p ~/.local/share/$(PACKAGE_NAME)/templates
	@cp bin/dsdep ~/.local/bin/dsdep
	@chmod +x ~/.local/bin/dsdep
	@cp templates/requirements.txt ~/.local/share/$(PACKAGE_NAME)/templates/
	@echo ""
	@echo "Installation complete!"
	@echo "Make sure ~/.local/bin is in your PATH:"
	@echo '  export PATH="$$HOME/.local/bin:$$PATH"'
	@echo ""
	@echo "Run 'dsdep --help' to get started."

uninstall:
	@echo "Uninstalling $(PACKAGE_NAME)..."
	rm -f $(DESTDIR)$(BINDIR)/dsdep
	rm -rf $(DESTDIR)$(SHAREDIR)
	rm -rf $(DESTDIR)$(DOCDIR)
	@echo "Uninstallation complete."

# Build Debian package
deb: clean
	@echo "Building Debian package..."
	dpkg-buildpackage -us -uc -b
	@echo ""
	@echo "Debian package built! Find it in the parent directory."
	@ls -la ../$(PACKAGE_NAME)_$(VERSION)*.deb 2>/dev/null || true

# Build RPM package (using alien to convert from deb)
rpm: deb
	@echo "Building RPM package from deb..."
	@which alien > /dev/null 2>&1 || { echo "Error: alien not found. Install with:"; echo "  sudo apt-get install alien"; exit 1; }
	cd .. && sudo alien --to-rpm --scripts $(PACKAGE_NAME)_$(VERSION)*.deb
	@echo ""
	@echo "RPM package built! Find it in the parent directory."

# Run tests
test:
	@echo "Running tests..."
	@echo "Checking bash syntax..."
	@bash -n bin/dsdep && echo "Syntax OK!"
	@echo ""
	@echo "Checking shellcheck (if available)..."
	@which shellcheck > /dev/null 2>&1 && shellcheck bin/dsdep || echo "shellcheck not installed, skipping..."
	@echo ""
	@echo "Running --help..."
	@bash bin/dsdep --help > /dev/null && echo "--help works!"
	@echo ""
	@echo "Running --version..."
	@bash bin/dsdep --version
	@echo ""
	@echo "All tests passed!"

clean:
	@echo "Cleaning build artifacts..."
	rm -rf debian/.debhelper
	rm -rf debian/dsdep
	rm -f debian/dsdep.debhelper.log
	rm -f debian/dsdep.substvars
	rm -f debian/files
	rm -rf debian/tmp
	@echo "Clean complete."

# Create source tarball for distribution
dist: clean
	@echo "Creating source tarball..."
	mkdir -p dist
	tar -czvf dist/$(PACKAGE_NAME)-$(VERSION).tar.gz \
		--transform 's,^,$(PACKAGE_NAME)-$(VERSION)/,' \
		bin templates debian Makefile README.md LICENSE
	@echo ""
	@echo "Source tarball created: dist/$(PACKAGE_NAME)-$(VERSION).tar.gz"

# Quick install script for users
install-script:
	@echo "#!/bin/bash"
	@echo "# Quick install script for dsdep"
	@echo "set -e"
	@echo 'echo "Installing dsdep..."'
	@echo "sudo mkdir -p /usr/local/bin"
	@echo "sudo curl -L https://raw.githubusercontent.com/ripiktech/dsdep/main/bin/dsdep -o /usr/local/bin/dsdep"
	@echo "sudo chmod +x /usr/local/bin/dsdep"
	@echo 'echo "dsdep installed successfully!"'
	@echo "dsdep --version"
