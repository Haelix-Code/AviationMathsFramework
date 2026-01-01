public enum AltitudeConversionError: Error, Equatable {
    case missingGroundElevation
    case missingQNH
    case missingTemperatureProfile
    case insufficientContext(from: VerticalReference, to: VerticalReference)
    
    public var localizedDescription: String {
        switch self {
        case .missingGroundElevation:
            return "Ground elevation required for AGL conversions"
        case .missingQNH:
            return "QNH required for pressure altitude conversions"
        case .missingTemperatureProfile:
            return "Sea level temperature and lapse rate required for true altitude conversions"
        case .insufficientContext(let from, let to):
            return "Cannot convert from \(from.abbreviation) to \(to.abbreviation) with current context"
        }
    }
}
