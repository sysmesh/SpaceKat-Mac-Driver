# SpaceKat-Mac-Driver Project Issues

## Known Limitations
- Requires foohid kernel extension to be installed for virtual HID device creation
- Uses IOKit framework for raw HID report access
- Uses CoreBluetooth for device discovery
- Uses GameController framework for device management

## Potential Challenges
- Compatibility with newer macOS versions
- Performance considerations for real-time 6DOF reporting
- Proper handling of device connection/disconnection events
- Calibration accuracy for different mouse models

## Dependencies
- foohid kernel extension (must be installed separately)
- macOS 10.15+ (for compatibility with IOKit and CoreBluetooth)

## Implementation Concerns
- Need to properly handle the HID report format from SpaceKat mouse
- Need to implement the foohid kernel extension integration correctly
- Need to ensure low-latency performance for CAD applications
- Need to handle device connection/disconnection gracefully
- Need to properly implement axis calibration functionality