import Foundation
import CoreGraphics

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