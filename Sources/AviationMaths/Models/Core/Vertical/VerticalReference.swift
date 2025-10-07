import Foundation

public enum VerticalReference: String, Codable, CaseIterable, Sendable {
    case agl = "AGL"
    case amsl = "AMSL"
    case pressureAltitude = "PA"
    case trueAltitude = "TA"
    case flightLevel = "FL"
    
    public var abbreviation: String { rawValue }
    
    public var description: String {
        switch self {
        case .agl: return "Above Ground Level"
        case .amsl: return "Above Mean Sea Level"
        case .pressureAltitude: return "Pressure Altitude"
        case .trueAltitude: return "True Altitude"
        case .flightLevel: return "Flight Level"
        }
    }
}
