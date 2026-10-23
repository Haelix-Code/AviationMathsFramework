import Foundation

extension Altitude {

    public var canConvertToAGL: Bool {
        switch reference {
        case .agl:
            return true
        case .amsl:
            return context.canCalculateAGL
        case .pressureAltitude:
            return context.canCalculatePressureAltitude && context.canCalculateAGL
        case .trueAltitude:
            return context.canCalculateTrueAltitude && context.canCalculateAGL
        case .geopotential:
            // Geopotential → True (always) → indicated AMSL (needs temp profile) → AGL
            // (needs ground elevation), matching the .trueAltitude case above.
            return context.canCalculateTrueAltitude && context.canCalculateAGL
        }
    }

    public var canConvertToAMSL: Bool {
        switch reference {
        case .agl:
            return context.canCalculateAGL
        case .amsl:
            return true
        case .pressureAltitude:
            return context.canCalculatePressureAltitude
        case .trueAltitude:
            return context.canCalculateTrueAltitude
        case .geopotential:
            // Geopotential → True (always possible) → AMSL (needs temp profile)
            return context.canCalculateTrueAltitude
        }
    }

    public var canConvertToPressureAltitude: Bool {
        switch reference {
        case .agl:
            return context.canCalculateAGL && context.canCalculatePressureAltitude
        case .amsl:
            return context.canCalculatePressureAltitude
        case .pressureAltitude:
            return true
        case .trueAltitude:
            return context.canCalculateTrueAltitude && context.canCalculatePressureAltitude
        case .geopotential:
            // Geopotential → True (always) → PA (needs temp profile + QNH)
            return context.canCalculateTrueAltitude && context.canCalculatePressureAltitude
        }
    }

    public var canConvertToTrueAltitude: Bool {
        switch reference {
        case .agl:
            return context.canCalculateAGL && context.canCalculateTrueAltitude
        case .amsl:
            return context.canCalculateTrueAltitude
        case .pressureAltitude:
            return context.canCalculatePressureAltitude && context.canCalculateTrueAltitude
        case .trueAltitude:
            return true
        case .geopotential:
            // Geopotential to True is a pure geometric transformation, always possible
            return true
        }
    }

    /// Geopotential altitude requires true altitude, which requires a temperature profile
    public var canConvertToGeopotential: Bool {
        switch reference {
        case .geopotential:
            return true
        case .trueAltitude:
            // True to Geopotential is a pure geometric transformation, always possible
            return true
        case .agl:
            return context.canCalculateAGL && context.canCalculateTrueAltitude
        case .amsl:
            return context.canCalculateTrueAltitude
        case .pressureAltitude:
            return context.canCalculatePressureAltitude && context.canCalculateTrueAltitude
        }
    }

    public func canConvert(to targetReference: VerticalReference) -> Bool {
        switch targetReference {
        case .agl: return canConvertToAGL
        case .amsl: return canConvertToAMSL
        case .pressureAltitude: return canConvertToPressureAltitude
        case .trueAltitude: return canConvertToTrueAltitude
        case .geopotential: return canConvertToGeopotential
        }
    }

    // MARK: - Safe Conversions (Return Optional)

    @available(*, deprecated, message: "Use `try? value(in: .agl)`.")
    public var aglIfPossible: Measurement<UnitLength>? {
        try? value(in: .agl)
    }

    @available(*, deprecated, message: "Use `try? value(in: .amsl)`.")
    public var amslIfPossible: Measurement<UnitLength>? {
        try? value(in: .amsl)
    }

    @available(*, deprecated, message: "Use `try? value(in: .pressureAltitude)`.")
    public var pressureAltitudeIfPossible: Measurement<UnitLength>? {
        try? value(in: .pressureAltitude)
    }

    @available(*, deprecated, message: "Use `try? value(in: .trueAltitude)`.")
    public var trueAltitudeIfPossible: Measurement<UnitLength>? {
        try? value(in: .trueAltitude)
    }

    @available(*, deprecated, message: "Use `try? value(in: .geopotential)`.")
    public var geopotentialIfPossible: Measurement<UnitLength>? {
        try? value(in: .geopotential)
    }

}
