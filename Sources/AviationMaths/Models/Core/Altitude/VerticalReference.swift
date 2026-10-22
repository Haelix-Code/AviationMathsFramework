/// - `.amsl` is *indicated* altitude: QNH-referenced, assuming the ISA lapse rate below the
///   reference pressure, with no correction for the actual (non-standard) temperature profile.
/// - `.agl` is barometric/QFE-style height above the airfield: `amsl − groundElevation`, using
///   the same QNH/ISA assumption as `.amsl`, not a radar-altimeter geometric height. Like real
///   QFE, it shares AMSL's non-ISA error — that is expected, not a bug.
/// - `.pressureAltitude` is referenced to the ISA standard pressure (1013.25 hPa) rather than
///   local QNH. It equals `.geopotential` only on a standard day; otherwise converting between
///   them goes through `.trueAltitude` and needs the temperature profile.
/// - `.trueAltitude` is the temperature-corrected *geometric* altitude above sea level — the
///   only reference here that depends on the actual (non-ISA) temperature profile.
/// - `.geopotential` is `.trueAltitude` adjusted for the variation of gravity with height
///   (constant g₀), per the ISA definition.
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
