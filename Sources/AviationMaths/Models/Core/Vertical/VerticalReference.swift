
public enum VerticalReference: String, Codable, CaseIterable, Sendable {
    case agl
    case amsl
    case pressureAltitude
    case trueAltitude
    
    public var abbreviation: String {
        switch self {
        case .agl: return "AGL"
        case .amsl: return "AMSL"
        case .pressureAltitude: return "PA"
        case .trueAltitude: return "True"
        }
    }
}
