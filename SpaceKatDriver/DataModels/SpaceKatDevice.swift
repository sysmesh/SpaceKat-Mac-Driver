import Foundation

/// Represents a SpaceKat device with connection state
public struct SpaceKatDevice: Codable, Identifiable {
    public var id = UUID()
    public var name: String
    public var vendorID: UInt16
    public var productID: UInt16
    public var connectionState: ConnectionState
    
    public init(name: String = "", vendorID: UInt16 = 0, productID: UInt16 = 0, connectionState: ConnectionState = .disconnected) {
        self.name = name
        self.vendorID = vendorID
        self.productID = productID
        self.connectionState = connectionState
    }
}

/// Connection states for SpaceKat devices
public enum ConnectionState: String, Codable {
    case disconnected
    case connected
    case active
    case calibrating
    case error
}