import Foundation

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