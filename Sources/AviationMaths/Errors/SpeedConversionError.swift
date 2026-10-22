public enum SpeedConversionError: Error, Equatable {
    case missingPressureAltitude
    case missingDensity
    case missingTemperature
    case insufficientContext(conversion: String)

    public var localizedDescription: String {
        switch self {
        case .missingPressureAltitude:
            return "Pressure altitude required for this speed conversion"
        case .missingDensity:
            return "Density required for this speed conversion"
        case .missingTemperature:
            return "Temperature required for this speed conversion"
        case .insufficientContext(let conversion):
            return "Insufficient context for conversion: \(conversion)"
        }
    }
}
