import Foundation

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