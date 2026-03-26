import SwiftUI

@main
struct SpaceKatDriverApp: App {
    var body: some Scene {
        MenuBarExtra("SpaceKat Driver", systemImage: "mouse") {
            SpaceKatDriverView()
        }
        .menuBarExtraStyle(.menu)
    }
}

struct SpaceKatDriverView: View {
    @StateObject private var deviceManager = DeviceManager()
    
    var body: some View {
        VStack(spacing: 10) {
            Text("SpaceKat 6DOF Driver")
                .font(.headline)
            
            if deviceManager.isScanning {
                Text("Scanning for devices...")
                    .foregroundColor(.secondary)
            } else {
                Text("Not scanning")
                    .foregroundColor(.secondary)
            }
            
            if let device = deviceManager.connectedDevice {
                Text("Connected: \(device.name)")
                    .foregroundColor(.green)
            } else {
                Text("No device connected")
                    .foregroundColor(.red)
            }
            
            Button("Start Scan") {
                deviceManager.startScanning()
            }
            .disabled(deviceManager.isScanning)
            
            Button("Stop Scan") {
                deviceManager.stopScanning()
            }
            .disabled(!deviceManager.isScanning)
            
            Button("Connect") {
                // Connect to first discovered device
                if let firstDevice = deviceManager.discoveredDevices.first {
                    deviceManager.connectToDevice(firstDevice)
                }
            }
            .disabled(deviceManager.discoveredDevices.isEmpty)
            
            Button("Disconnect") {
                deviceManager.disconnectDevice()
            }
            .disabled(deviceManager.connectedDevice == nil)
        }
        .padding()
    }
}