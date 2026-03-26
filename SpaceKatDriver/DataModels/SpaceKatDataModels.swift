import Foundation
import Combine
import CoreGraphics

// MARK: - Data Models

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

/// Vector representing 6DOF data
public struct Vector6D: Codable {
    public var x: Int16
    public var y: Int16
    public var z: Int16
    public var rx: Int16
    public var ry: Int16
    public var rz: Int16
    
    public init() {
        x = 0
        y = 0
        z = 0
        rx = 0
        ry = 0
        rz = 0
    }
    
    public init(x: Int16, y: Int16, z: Int16, rx: Int16, ry: Int16, rz: Int16) {
        self.x = x
        self.y = y
        self.z = z
        self.rx = rx
        self.ry = ry
        self.rz = rz
    }
    
    /// Convert to normalized vector for use with CAD applications
    public func normalized() -> NormalizedVector6D {
        return NormalizedVector6D(
            translation: SIMD3<Double>(x: Double(x) / 350.0, y: Double(y) / 350.0, z: Double(z) / 350.0),
            rotation: SIMD3<Double>(x: Double(rx) / 350.0, y: Double(ry) / 350.0, z: Double(rz) / 350.0)
        )
    }
}

/// Normalized 6DOF vector for CAD applications
public struct NormalizedVector6D: Codable {
    public var translation: SIMD3<Double>
    public var rotation: SIMD3<Double>
    
    public init() {
        self.translation = SIMD3<Double>(x: 0, y: 0, z: 0)
        self.rotation = SIMD3<Double>(x: 0, y: 0, z: 0)
    }
    
    public init(translation: SIMD3<Double>, rotation: SIMD3<Double>) {
        self.translation = translation
        self.rotation = rotation
    }
    
    public var magnitude: Double {
        let vector = translation
        return Double(sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z))
    }
}

/// HID 6DOF report structure
public struct HID6DOFReport: Codable {
    public var reportID: UInt8
    public var x: Int16
    public var y: Int16
    public var z: Int16
    public var rx: Int16
    public var ry: Int16
    public var rz: Int16
    public var buttons: UInt8
    
    public var reportData: Data {
        var buffer = Data()
        buffer.append(reportID)
        
        let xBytes = Data(bytes: [UInt8((x >> 8) & 0xFF), UInt8(x & 0xFF)])
        buffer.append(contentsOf: xBytes)
        
        let yBytes = Data(bytes: [UInt8((y >> 8) & 0xFF), UInt8(y & 0xFF)])
        buffer.append(contentsOf: yBytes)
        
        let zBytes = Data(bytes: [UInt8((z >> 8) & 0xFF), UInt8(z & 0xFF)])
        buffer.append(contentsOf: zBytes)
        
        let rxBytes = Data(bytes: [UInt8((rx >> 8) & 0xFF), UInt8(rx & 0xFF)])
        buffer.append(contentsOf: rxBytes)
        
        let ryBytes = Data(bytes: [UInt8((ry >> 8) & 0xFF), UInt8(ry & 0xFF)])
        buffer.append(contentsOf: ryBytes)
        
        let rzBytes = Data(bytes: [UInt8((rz >> 8) & 0xFF), UInt8(rz & 0xFF)])
        buffer.append(contentsOf: rzBytes)
        
        buffer.append(buttons)
        
        return buffer
    }
}

/// Settings for the SpaceKat driver
public struct Settings: Codable {
    public var sensitivity: Double
    public var globalDeadzone: Double
    public var invertedAxes: Set<Int>
    public var launchAtLogin: Bool
    
    public static var `default`: Settings {
        Settings(
            sensitivity: 1.0,
            globalDeadzone: 0.05,
            invertedAxes: [],
            launchAtLogin: false
        )
    }
    
    public init() {
        self.sensitivity = 1.0
        self.globalDeadzone = 0.05
        self.invertedAxes = []
        self.launchAtLogin = false
    }
    
    public init(sensitivity: Double, globalDeadzone: Double, invertedAxes: Set<Int>, launchAtLogin: Bool) {
        self.sensitivity = sensitivity
        self.globalDeadzone = globalDeadzone
        self.invertedAxes = invertedAxes
        self.launchAtLogin = launchAtLogin
    }
}

/// Axis calibration data
public struct AxisCalibration: Codable {
    public var axisMapping: [Int: Int]
    public var polarity: [Int: AxisPolarity]
    public var deadzone: [Int: Double]
    
    public init() {
        self.axisMapping = [0:0, 1:1, 2:2, 3:3, 4:4, 5:5]
        self.polarity = [:]
        self.deadzone = [:]
    }
    
    public init(axisMapping: [Int: Int], polarity: [Int: AxisPolarity], deadzone: [Int: Double]) {
        self.axisMapping = axisMapping
        self.polarity = polarity
        self.deadzone = deadzone
    }
    
    public static var `default`: AxisCalibration {
        AxisCalibration(
            axisMapping: [0:0, 1:1, 2:2, 3:3, 4:4, 5:5],
            polarity: [0: .normal, 1: .normal, 2: .normal, 3: .normal, 4: .normal, 5: .normal],
            deadzone: [0:0.0, 1:0.0, 2:0.0, 3:0.0, 4:0.0, 5:0.0]
        )
    }
}

/// Axis polarity for calibration
public enum AxisPolarity: String, Codable {
    case normal
    case inverted
}