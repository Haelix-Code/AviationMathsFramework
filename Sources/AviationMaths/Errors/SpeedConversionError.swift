import Foundation

/// A speed conversion needs a quantity that the context can't supply.
public enum SpeedConversionError: Error, Equatable, Sendable, LocalizedError {
    /// Needs a density, a measured pressure and temperature, or a pressure altitude.
    case missingDensity
    /// Needs a temperature or a pressure altitude.
    case missingSpeedOfSound
    /// Needs a measured pressure or a pressure altitude.
    case missingRelativePressure

    public var errorDescription: String? {
        switch self {
        case .missingDensity:
            return "Air density needs a density, a measured pressure and temperature, or a pressure altitude"
        case .missingSpeedOfSound:
            return "Speed of sound needs a temperature or a pressure altitude"
        case .missingRelativePressure:
            return "Relative pressure needs a measured pressure or a pressure altitude"
        }
    }
}
