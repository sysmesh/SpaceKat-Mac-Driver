# SpaceKat-Mac-Driver Project Decisions

## Technical Architecture
- Using foohid kernel extension instead of Apple's newer HIDVirtualDevice for compatibility with older macOS versions
- Implementing a complete 6DOF HID translation pipeline
- Using IOKit framework for raw HID report access
- Using CoreBluetooth for device discovery
- Using GameController framework for device management

## Development Approach
- Following Apple's Swift style guide
- Using SwiftUI for UI components
- Using LSUIElement to hide dock icon (menu bar only app)
- Focusing on bridging SpaceKat hardware to CAD applications

## Code Quality
- No direct file system access (uses only standard macOS APIs)
- No UI elements in the main application (menu bar only)
- No external dependencies beyond standard macOS frameworks
- No use of deprecated APIs (uses modern Swift and IOKit)

## Implementation Strategy
Based on the technical design document, the implementation will follow this approach:
1. Device Detection & Connection - Handle Bluetooth device discovery and connection
2. 6DOF Input Capture - Parse raw HID reports from the SpaceKat mouse
3. Virtual HID Device Creation - Use foohid to create a virtual HID device
4. Global Sensitivity & Deadzone - Apply user-configurable settings
5. Axis Calibration - Implement calibration wizard for proper axis mapping
6. Device Selection Menu - Allow users to select between multiple devices
7. Settings Panel - Provide configuration options for the driver
8. Menu Bar Presence - Ensure the app appears in the menu bar only

## HID Report Parsing Approach
The HID report parsing will be implemented in the HID6DOFReport struct with:
- Proper parsing of 16-byte reports from SpaceKat mouse
- Little-endian byte order handling
- Error handling for malformed reports
- Support for translation (X, Y, Z) and rotation (Pitch, Roll, Yaw) data
- Button data handling