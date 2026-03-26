import Foundation
import Combine

/// Main device manager that coordinates all components
public class DeviceManager: ObservableObject {
    @Published public var connectedDevice: SpaceKatDevice?
    @Published public var isScanning = false
    @Published public var discoveredDevices: [SpaceKatDevice] = []
    @Published public var deviceState: ConnectionState = .disconnected
    
    private let bluetoothManager = BluetoothManager()
    private let virtualHIDManager = VirtualHIDManager()
    private let settingsService = SettingsService()
    private let calibrationEngine = CalibrationEngine()
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        bluetoothManager.$discoveredDevices
            .assign(to: \.discoveredDevices, on: self)
            .store(in: &cancellables)
        
        bluetoothManager.$connectedDevice
            .assign(to: \.connectedDevice, on: self)
            .store(in: &cancellables)
        
        bluetoothManager.$isScanning
            .assign(to: \.isScanning, on: self)
            .store(in: &cancellables)
    }
    
    public func startScanning() {
        bluetoothManager.startScanning()
    }
    
    public func stopScanning() {
        bluetoothManager.stopScanning()
    }
    
    public func connectToDevice(_ device: SpaceKatDevice) {
        bluetoothManager.connectToDevice(device)
    }
    
    public func disconnectDevice() {
        bluetoothManager.disconnectDevice()
    }
    
    public func startHIDProcessing() {
        // Start processing HID reports
    }
    
    public func stopHIDProcessing() {
        // Stop processing HID reports
    }
}