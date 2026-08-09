APP_NAME    := Homelab
BUNDLE      := $(APP_NAME).app
BUILD_DIR   := .build/release
STAGE_DIR   := .build/$(BUNDLE)
INSTALL_DIR := /Applications

.PHONY: all test build bundle install clean run

all: bundle

test:
	swift test

build:
	swift build -c release --product HomelabMenuBar

# SwiftPM emits a bare executable; MenuBarExtra needs a real bundle so that
# LSUIElement is honoured and the app has no Dock icon.
bundle: build
	rm -rf "$(STAGE_DIR)"
	mkdir -p "$(STAGE_DIR)/Contents/MacOS"
	mkdir -p "$(STAGE_DIR)/Contents/Resources"
	cp "$(BUILD_DIR)/HomelabMenuBar" "$(STAGE_DIR)/Contents/MacOS/HomelabMenuBar"
	cp Resources/Info.plist "$(STAGE_DIR)/Contents/Info.plist"
	codesign --force --deep --sign - "$(STAGE_DIR)"
	@echo "Built $(STAGE_DIR)"

install: bundle
	rm -rf "$(INSTALL_DIR)/$(BUNDLE)"
	cp -R "$(STAGE_DIR)" "$(INSTALL_DIR)/$(BUNDLE)"
	@echo "Installed $(INSTALL_DIR)/$(BUNDLE)"
	@echo "Launch it with: open '$(INSTALL_DIR)/$(BUNDLE)'"

run: bundle
	open "$(STAGE_DIR)"

clean:
	swift package clean
	rm -rf .build
