# PROJECT KNOWLEDGE BASE

**Generated:** 2026-03-25 10:51:00
**Commit:** 1234567
**Branch:** main

## OVERVIEW
SpaceKat-Mac-Driver is a macOS driver that translates SpaceKat 6DOF Bluetooth mouse HID reports into standard HID joystick format for CAD applications like FreeCAD, Blender, and BambuLab Studio. It uses the foohid kernel extension to create a virtual HID device.

## STRUCTURE
```
SpaceKat-Mac-Driver/
├── SpaceKatDriver/              # Main application directory
│   ├── DataModels/              # Data models for HID reports and device state
│   └── Info.plist               # Application configuration
├── SpaceKatDriverTests/         # Test files
├── Sources/                     # Source code (empty in this project)
├── Resources/                  # Resource files (empty in this project)
├── project.yml                 # Project configuration (Swift Package Manager)
├── docs/                       # Documentation directory
│   └── TechnicalDesign.md      # Technical design document
├── README.md                   # Project overview
└── CLAUDE.md                   # Claude tool calling instructions
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Device Detection | SpaceKatDriver/DataModels/SpaceKatDevice.swift | Contains device identification logic |
| HID Parsing | SpaceKatDriver/DataModels/HID6DOFReport.swift | Parses raw HID reports |
| Calibration | SpaceKatDriver/DataModels/AxisCalibration.swift | Axis calibration logic |
| Settings | SpaceKatDriver/DataModels/Settings.swift | Application settings |
| Virtual HID | SpaceKatDriver/Info.plist | Configuration for virtual HID device |
| Technical Design | docs/TechnicalDesign.md | Complete technical specification |

## CODE MAP
| Symbol | Type | Location | Refs | Role |
|--------|------|----------|------|------|
| Vector6D | struct | SpaceKatDriver/DataModels/Vector6D.swift | 1 | Core 6DOF data structure |
| HID6DOFReport | struct | SpaceKatDriver/DataModels/HID6DOFReport.swift | 1 | Raw HID report parser |
| SpaceKatDevice | struct | SpaceKatDriver/DataModels/SpaceKatDevice.swift | 1 | Device identification |
| AxisCalibration | struct | SpaceKatDriver/DataModels/AxisCalibration.swift | 1 | Axis calibration data |
| Settings | struct | SpaceKatDriver/DataModels/Settings.swift | 1 | Application settings |
| NormalizedVector6D | struct | SpaceKatDriver/DataModels/NormalizedVector6D.swift | 1 | Normalized 6DOF data |

## CONVENTIONS
- Uses Swift 5.9+ for macOS development
- Follows Apple's Swift style guide
- Uses IOKit for HID device access
- Uses foohid kernel extension for virtual HID device creation
- Uses LSUIElement to hide dock icon (menu bar only app)
- Uses SwiftUI for UI components

## ANTI-PATTERNS (THIS PROJECT)
- No direct file system access (uses only standard macOS APIs)
- No UI elements in the main application (menu bar only)
- No external dependencies beyond standard macOS frameworks
- No use of deprecated APIs (uses modern Swift and IOKit)

## UNIQUE STYLES
- Uses foohid kernel extension instead of Apple's newer HIDVirtualDevice (for compatibility with older macOS versions)
- Implements a complete 6DOF HID translation pipeline
- Uses a technical design document as the primary specification
- Focuses on bridging SpaceKat hardware to CAD applications

## COMMANDS
```bash
# Build the project
swift build

# Run tests
swift test

# Build for release
swift build --configuration release

# Clean build
swift build --clean
```

## NOTES
- Requires foohid kernel extension to be installed for virtual HID device creation
- Uses IOKit framework for raw HID report access
- Uses CoreBluetooth for device discovery
- Uses GameController framework for device management
- Uses AppKit and SwiftUI for UI components