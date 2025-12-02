import Foundation

extension Altitude {
    // MARK: - Capability Checks

    /// Whether this altitude can be converted to AGL.
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
        }
    }

    /// Whether this altitude can be converted to AMSL.
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
        }
    }

    /// Whether this altitude can be converted to pressure altitude.
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
        }
    }

    /// Whether this altitude can be converted to true altitude.
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
        }
    }

    /// Whether this altitude can be converted to the specified reference.
    public func canConvert(to targetReference: VerticalReference) -> Bool {
        switch targetReference {
        case .agl: return canConvertToAGL
        case .amsl: return canConvertToAMSL
        case .pressureAltitude: return canConvertToPressureAltitude
        case .trueAltitude: return canConvertToTrueAltitude
        }
    }

    // MARK: - Safe Conversions (Return Optional)

    /// Attempts to convert to AGL. Returns nil if context lacks required data.
    public var aglIfPossible: Measurement<UnitLength>? {
        guard canConvertToAGL else { return nil }
        return convertToAGL()
    }

    /// Attempts to convert to AMSL. Returns nil if context lacks required data.
    public var amslIfPossible: Measurement<UnitLength>? {
        guard canConvertToAMSL else { return nil }
        return convertToAMSL()
    }

    /// Attempts to convert to pressure altitude. Returns nil if context lacks required data.
    public var pressureAltitudeIfPossible: Measurement<UnitLength>? {
        guard canConvertToPressureAltitude else { return nil }
        return convertToPressureAltitude()
    }

    /// Attempts to convert to true altitude. Returns nil if context lacks required data.
    public var trueAltitudeIfPossible: Measurement<UnitLength>? {
        guard canConvertToTrueAltitude else { return nil }
        return convertToTrueAltitude()
    }

}
