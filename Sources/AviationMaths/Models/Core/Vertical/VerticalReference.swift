import Foundation

public enum VerticalReference: String, Codable, CaseIterable, Sendable {
    case agl = "AGL"                // FAA: Absolute Altitude
    case amsl = "AMSL"              // FAA: True Altitude
    case pressureAltitude = "PA"    // FAA: Pressure Altitude
//    case densityAltitude = "DA"     // FAA: Density Altitude
    
    public var abbreviation: String { rawValue }
    
    public var description: String {
        switch self {
        case .agl: return "Above Ground Level"
        case .amsl: return "Above Mean Sea Level"
        case .pressureAltitude: return "Pressure Altitude"
//        case .densityAltitude: return "Density Altitude"
        }
    }
}
