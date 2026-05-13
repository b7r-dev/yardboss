# Makefile for yardboss
#
# Install:
#   make install              # Install to /usr/local (default)
#   make PREFIX=$HOME/.local  # Install to custom prefix
#
# Uninstall:
#   make uninstall

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share/yardboss

.PHONY: install uninstall

install:
	@echo "Installing yardboss to $(BINDIR) ..."
	@mkdir -p $(BINDIR) $(DATADIR)
	install -m 755 yardboss $(BINDIR)/yardboss
	install -m 644 yardboss.conf.example $(DATADIR)/yardboss.conf.example
	@echo "Done."
	@echo ""
	@echo "Copy $(DATADIR)/yardboss.conf.example to your project as yardboss.conf"

uninstall:
	rm -f $(BINDIR)/yardboss
	rm -rf $(DATADIR)
