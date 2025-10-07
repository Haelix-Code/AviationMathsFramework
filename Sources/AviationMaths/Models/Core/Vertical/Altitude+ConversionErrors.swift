public enum AltitudeConversionError: Error {
    case missingQNH
    case missingTemperature
    case missingGroundElevation
    case missingTemperatureOrElevation
    case incompatibleReferences(from: VerticalReference, to: VerticalReference)
    
    public var errorDescription: String? {
        switch self {
        case .missingQNH:
            return "QNH (altimeter setting) required for this conversion"
        case .missingTemperature:
            return "Surface temperature required for true altitude conversion"
        case .missingGroundElevation:
            return "Ground elevation required for AGL conversion"
        case .missingTemperatureOrElevation:
            return "Both surface temperature and ground elevation required"
        case .incompatibleReferences(let from, let to):
            return "Cannot convert from \(from.rawValue) to \(to.rawValue)"
        }
    }
}
