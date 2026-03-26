import Foundation

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