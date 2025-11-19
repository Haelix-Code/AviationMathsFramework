import Foundation

public enum SpeedReference: String, Codable, CaseIterable, Sendable {
    case calibratedAirspeed  // CAS - corrected instrument reading
    case equivalentAirspeed  // EAS - CAS corrected for compressibility
    case trueAirspeed       // TAS - actual speed through air mass
    case machNumber         // Mach - ratio to speed of sound
    
    public var abbreviation: String {
        switch self {
        case .calibratedAirspeed: return "CAS"
        case .equivalentAirspeed: return "EAS"
        case .trueAirspeed: return "TAS"
        case .machNumber: return "Mach"
        }
    }
    
    public var description: String {
        switch self {
        case .calibratedAirspeed: return "Calibrated Airspeed"
        case .equivalentAirspeed: return "Equivalent Airspeed"
        case .trueAirspeed: return "True Airspeed"
        case .machNumber: return "Mach Number"
        }
    }
}
