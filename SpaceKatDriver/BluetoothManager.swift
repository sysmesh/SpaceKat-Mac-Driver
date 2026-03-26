import Foundation
import CoreBluetooth
import Combine

/// Manager for handling Bluetooth device discovery and connection for SpaceKat 6DOF mice
public final class BluetoothManager: NSObject, CBCentralManagerDelegate {
    // MARK: - Properties
    
    /// The central manager for Bluetooth operations
    private var centralManager: CBCentralManager!
    
    /// Current discovered devices
    @Published public var discoveredDevices: [SpaceKatDevice] = []
    
    /// Currently connected device
    @Published public var connectedDevice: SpaceKatDevice?
    
    /// Current scanning state
    @Published public var isScanning = false
    
    /// Current Bluetooth state
    @Published public var bluetoothState: CBManagerState = .unknown
    
    /// Timer for device timeout
    private var deviceTimeoutTimer: Timer?
    
    /// Set of discovered device identifiers to prevent duplicates
    private var discoveredDeviceIDs: Set<UUID> = []
    
    /// Current device connection state
    private var deviceConnectionState: ConnectionState = .disconnected
    
    // MARK: - Initialization
    
    /// Initialize the Bluetooth manager
    override public init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    // MARK: - Public Methods
    
    /// Start scanning for Bluetooth devices
    public func startScanning() {
        guard bluetoothState == .poweredOn else {
            return
        }
        
        isScanning = true
        discoveredDeviceIDs.removeAll()
        discoveredDevices.removeAll()
        
        // Start scanning for all devices (no service filter)
        centralManager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ])
    }
    
    /// Stop scanning for Bluetooth devices
    public func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    /// Connect to a specific device
    public func connectToDevice(_ device: SpaceKatDevice) {
        guard let peripheral = findPeripheral(for: device) else {
            return
        }
        
        // Update device state to connected
        updateDeviceState(device, to: .connected)
        centralManager.connect(peripheral, options: nil)
    }
    
    /// Disconnect from the currently connected device
    public func disconnectDevice() {
        guard let device = connectedDevice else {
            return
        }
        
        if let peripheral = findPeripheral(for: device) {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        
        updateDeviceState(device, to: .disconnected)
        connectedDevice = nil
    }
    
    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        
        switch central.state {
        case .poweredOn:
            // Start scanning when Bluetooth is powered on
            startScanning()
            
        case .poweredOff, .unauthorized, .unsupported:
            // Stop scanning and clear devices when Bluetooth is not available
            stopScanning()
            discoveredDevices.removeAll()
            connectedDevice = nil
            
        default:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if this is a SpaceKat device by name or characteristics
        guard let deviceName = peripheral.name else {
            return
        }
        
        // SpaceKat devices typically have names like "SpaceMouse", "SpaceKat", or "SpaceNavigator"
        if isSpaceKatDevice(name: deviceName) {
            // Create or update device in our list
            let device = createSpaceKatDevice(from: peripheral, advertisementData: advertisementData)
            
            // Update the device list
            if let index = discoveredDevices.firstIndex(where: { $0.deviceID == device.deviceID }) {
                discoveredDevices[index] = device
            } else {
                discoveredDevices.append(device)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Update device state to active
        if let device = connectedDevice {
            updateDeviceState(device, to: .active)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle connection failure
        if let device = connectedDevice {
            updateDeviceState(device, to: .error)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Handle disconnection
        if let device = connectedDevice {
            updateDeviceState(device, to: .disconnected)
            connectedDevice = nil
        }
    }
    
    // MARK: - Private Methods
    
    /// Check if a device name matches SpaceKat device patterns
    private func isSpaceKatDevice(name: String) -> Bool {
        // SpaceKat devices typically have names like:
        // - "SpaceMouse"
        // - "SpaceKat"
        // - "SpaceNavigator"
        // - "3D Mouse"
        // - "SpaceMouse Compact"
        // - "SpaceMouse Pro"
        
        let lowerName = name.lowercased()
        return lowerName.contains("spacekat") || 
               lowerName.contains("spacemouse") || 
               lowerName.contains("spacenavigator") ||
               lowerName.contains("3d mouse") ||
               lowerName.contains("space mouse")
    }
    
    /// Create a SpaceKatDevice from a CBPeripheral
    private func createSpaceKatDevice(from peripheral: CBPeripheral, advertisementData: [String : Any]) -> SpaceKatDevice {
        // Create a new device with the peripheral's identifier
        var device = SpaceKatDevice(
            deviceID: peripheral.identifier,
            name: peripheral.name ?? "Unknown Device",
            vendorID: 0x046D, // 3Dconnexion vendor ID (common for SpaceMouse devices)
            productID: 0x0000, // Will be set when we get more info
            connectionState: .disconnected
        )
        
        // Try to get more specific device information from advertisement data
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            // Parse manufacturer data if available
            // This is where we could extract more specific device information
        }
        
        // If this device is already connected, update its state
        if let connectedDevice = connectedDevice, connectedDevice.deviceID == device.deviceID {
            device.connectionState = .connected
        }
        
        return device
    }
    
    /// Find a peripheral for a given device
    private func findPeripheral(for device: SpaceKatDevice) -> CBPeripheral? {
        // In a real implementation, we would maintain a mapping between devices and peripherals
        // For now, we'll just return nil as this is a simplified implementation
        return nil
    }
    
    /// Update device state
    private func updateDeviceState(_ device: SpaceKatDevice, to state: ConnectionState) {
        // Update the device in our list
        if let index = discoveredDevices.firstIndex(where: { $0.deviceID == device.deviceID }) {
            var updatedDevice = discoveredDevices[index]
            updatedDevice.connectionState = state
            discoveredDevices[index] = updatedDevice
            
            // If this is the connected device, update that too
            if connectedDevice?.deviceID == device.deviceID {
                connectedDevice = updatedDevice
            }
        }
    }
    
    /// Handle device timeout (not implemented in this simplified version)
    private func handleDeviceTimeout() {
        // In a more complete implementation, we would remove devices that haven't been seen in a while
    }
}