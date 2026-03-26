# SpaceKat-Mac-Driver Project Learnings

## Project Overview
This is a macOS driver that translates SpaceKat 6DOF Bluetooth mouse HID reports into standard HID joystick format for CAD applications like FreeCAD, Blender, and BambuLab Studio.

## Project Structure
- Main application directory: SpaceKatDriver/
- Data models in: SpaceKatDriver/DataModels/
- Xcode project: SpaceKatDriver.xcodeproj/
- Sources directory: Sources/ (empty in this project)
- Resources directory: Resources/ (empty in this project)
- Tests directory: SpaceKatDriverTests/ (empty in this project)

## Key Technical Details
- Uses foohid kernel extension to create a virtual HID device
- Uses IOKit for HID device access
- Uses CoreBluetooth for device discovery
- Uses GameController framework for device management
- Uses SwiftUI for UI components
- Uses LSUIElement to hide dock icon (menu bar only app)
- Uses Swift 5.9+ for macOS development

## Architecture Patterns
- Uses a technical design document as the primary specification
- Implements a complete 6DOF HID translation pipeline
- Focuses on bridging SpaceKat hardware to CAD applications
- Uses modern Swift style guide and Apple development practices

## Data Models
1. Vector6D.swift - Core 6DOF data structure with x, y, z, rx, ry, rz properties
2. HID6DOFReport.swift - Raw HID report parser with reportID, x, y, z, rx, ry, rz, buttons properties and reportData property
3. AxisCalibration.swift - Axis calibration data with axisMapping, polarity, and deadzone properties
4. NormalizedVector6D.swift - Normalized 6DOF data with translation and rotation SIMD3 properties
5. Settings.swift - Application settings with sensitivity, globalDeadzone, invertedAxes, and launchAtLogin properties
6. SpaceKatDevice.swift - Device identification with deviceID, name, vendorID, productID, and connectionState properties

## Development Constraints
- No direct file system access (uses only standard macOS APIs)
- No UI elements in the main application (menu bar only)
- No external dependencies beyond standard macOS frameworks
- No use of deprecated APIs (uses modern Swift and IOKit)

## HID Report Format (from Technical Design)
Based on the technical design document, the SpaceKat HID report format is:
- Report ID: 1 byte (0x01)
- Translation X: 2 bytes (little-endian, -350 to +350)
- Translation Y: 2 bytes (little-endian)
- Translation Z: 2 bytes (little-endian)
- Rotation Pitch: 2 bytes (little-endian)
- Rotation Roll: 2 bytes (little-endian)
- Rotation Yaw: 2 bytes (little-endian)
- Buttons: 1 byte
- Total: 16 bytes