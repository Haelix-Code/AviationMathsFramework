import Foundation

public enum SpeedConversionError: Error, LocalizedError {
    case missingPressureAltitude
    case missingDensity
    case missingTemperature
    case missingSpeedOfSound
    case invalidFunction(String)
    case insufficientContext(String)
    case other(String)

    public var errorDescription: String? {
        switch self {
        case .missingPressureAltitude:
            return "Pressure altitude required for this conversion"
        case .missingDensity:
            return "Density/temperature required for this conversion"
        case .missingTemperature:
            return "Temperature required for this conversion"
        case .missingSpeedOfSound:
            return "Speed of sound required for this conversion"
        case .invalidFunction(let details):
            return "Invalid function: \(details)"
        case .insufficientContext(let details):
            return "Insufficient context: \(details)"
        case .other(let details):
            return "Error: \(details)"
        }
    }
}
