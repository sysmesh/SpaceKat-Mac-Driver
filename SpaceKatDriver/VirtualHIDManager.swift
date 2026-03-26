import Foundation
import IOKit

/// Manager for creating and managing virtual HID devices using foohid
public class VirtualHIDManager {
    private let foohidBridge = foohidBridge()
    private var isDeviceCreated = false
    private var hasFoohidExtension = false
    
    /// HID descriptor for the SpaceKat 6DOF device
    /// Based on the technical design document (Section 6.3)
    private let virtualDeviceDescriptor: [UInt8] = [
        // Application Collection
        0x05, 0x01,         // Usage Page (Generic Desktop)
        0x09, 0x08,         // Usage (Multi-axis Controller)
        0xA1, 0x01,         // Collection (Application)
        
        // Physical - Translation Axes
        0x09, 0x01,         //   Usage (Pointer)
        0xA1, 0x00,         //   Collection (Physical)
        0x16, 0x00, 0x80,   //   Logical Min (-32768)
        0x26, 0xFF, 0x7F,   //   Logical Max (32767)
        0x09, 0x30,         //   Usage (X)
        0x09, 0x31,         //   Usage (Y)
        0x09, 0x32,         //   Usage (Z)
        0x75, 0x10,         //   Report Size (16 bits)
        0x95, 0x03,         //   Report Count (3)
        0x81, 0x02,         //   Input (Data, Var, Abs)
        
        // Rotation Axes
        0x09, 0x33,         //   Usage (Rx)
        0x09, 0x34,         //   Usage (Ry)
        0x09, 0x35,         //   Usage (Rz)
        0x95, 0x03,         //   Report Count (3)
        0x81, 0x02,         //   Input
        0xC0,               //   End Collection
        
        // Buttons
        0x05, 0x09,         //   Usage Page (Button)
        0x19, 0x01,         //   Usage Min
        0x29, 0x02,         //   Usage Max
        0x15, 0x00,         //   Logical Min (0)
        0x25, 0x01,         //   Logical Max (1)
        0x75, 0x01,         //   Report Size (1)
        0x95, 0x02,         //   Report Count (2)
        0x81, 0x02,         //   Input
        0x95, 0x06,         //   Padding
        0x81, 0x01,         //   Constant
        0xC0                // End Collection
    ]
    
    /// Initialize the virtual HID manager
    /// - Returns: True if initialization was successful
    public func initialize() -> Bool {
        // Check if foohid extension is available
        hasFoohidExtension = foohidBridge.initialize()
        return hasFoohidExtension
    }
    
    /// Create the virtual HID device
    /// - Returns: True if device was created successfully
    public func createDevice() -> Bool {
        guard !isDeviceCreated else {
            return true // Already created
        }
        
        guard hasFoohidExtension else {
            // Handle missing foohid extension gracefully
            return false
        }
        
        let success = foohidBridge.create(
            name: "SpaceKat 6DOF Mouse",
            descriptor: Data(virtualDeviceDescriptor),
            vendorID: 0x046D, // 3Dconnexion
            productID: 0x0000
        )
        
        isDeviceCreated = success
        return success
    }
    
    /// Send a 6DOF report to the virtual device
    /// - Parameter report: The HID report to send (16 bytes)
    public func sendReport(_ report: Data) {
        guard isDeviceCreated else {
            return
        }
        
        foohidBridge.send(report: report)
    }
    
    /// Destroy the virtual HID device
    /// - Returns: True if device was destroyed successfully
    public func destroyDevice() -> Bool {
        guard isDeviceCreated else {
            return true // Already destroyed
        }
        
        let success = foohidBridge.destroy()
        isDeviceCreated = !success
        return success
    }
    
    /// Clean up resources
    public func close() {
        destroyDevice()
        foohidBridge.close()
    }
    
    /// Check if foohid extension is available
    public var isFoohidAvailable: Bool {
        return hasFoohidExtension
    }
}