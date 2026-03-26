import Foundation
import CoreGraphics

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