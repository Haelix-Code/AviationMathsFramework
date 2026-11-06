import Foundation

public enum AltitudeConversionError: Error, Equatable, Sendable, LocalizedError {
    case missingGroundElevation
    case missingQNH
    case missingTemperatureProfile

    public var errorDescription: String? {
        switch self {
        case .missingGroundElevation:
            return "Ground elevation required for AGL conversions"
        case .missingQNH:
            return "QNH required for pressure altitude conversions"
        case .missingTemperatureProfile:
            return "Sea level temperature and lapse rate required for true altitude conversions"
        }
    }
}
