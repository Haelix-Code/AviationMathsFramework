import Foundation

public enum VerticalReference: String, Codable, CaseIterable, Sendable {
    case agl                // FAA: Absolute Altitude
    case amsl               // FAA: True Altitude
    case pressureAltitude   // FAA: Pressure Altitude
    case geopotentialAltitude
    
    public var abbreviation: String { rawValue }
    
    public var description: String {
        switch self {
        case .agl: return "Above Ground Level"
        case .amsl: return "Above Mean Sea Level"
        case .pressureAltitude: return "Pressure Altitude"
        case .geopotentialAltitude: return "Geopotential Altitude"
        }
    }
}
