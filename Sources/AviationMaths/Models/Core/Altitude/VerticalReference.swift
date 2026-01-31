public enum VerticalReference: String, Codable, CaseIterable, Sendable, Equatable, Hashable {
    case agl
    case amsl
    case pressureAltitude
    case trueAltitude
    case geopotential

    public var abbreviation: String {
        switch self {
        case .agl: return "AGL"
        case .amsl: return "AMSL"
        case .pressureAltitude: return "PA"
        case .trueAltitude: return "True"
        case .geopotential: return "Geopotential"
        }
    }
}
