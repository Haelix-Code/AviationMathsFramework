import Foundation

public struct Altitude: Codable, Hashable, Sendable {
    public let value: Measurement<UnitLength>
    public let reference: VerticalReference
    public let context: AltitudeContext

    public init(value: Measurement<UnitLength>, reference: VerticalReference, context: AltitudeContext) {
        self.value = value
        self.reference = reference
        self.context = context
    }

    // MARK: - Convenience Initializers

    public init(meters: Double, reference: VerticalReference, context: AltitudeContext) {
        self.init(value: .init(meters: meters), reference: reference, context: context)
    }

    public init(feet: Double, reference: VerticalReference, context: AltitudeContext) {
        self.init(value: .init(feet: feet), reference: reference, context: context)
    }

    // MARK: - Computed Properties for Each Reference

    /// Above ground level altitude.
    /// - Throws: `AltitudeConversionError` if the context lacks the data the conversion needs.
    public var agl: Measurement<UnitLength> {
        get throws(AltitudeConversionError) { try value(in: .agl) }
    }

    /// Above mean sea level altitude.
    /// - Throws: `AltitudeConversionError` if the context lacks the data the conversion needs.
    public var amsl: Measurement<UnitLength> {
        get throws(AltitudeConversionError) { try value(in: .amsl) }
    }

    /// Pressure altitude.
    /// - Throws: `AltitudeConversionError` if the context lacks the data the conversion needs.
    public var pressureAltitude: Measurement<UnitLength> {
        get throws(AltitudeConversionError) { try value(in: .pressureAltitude) }
    }

    /// True altitude.
    /// - Throws: `AltitudeConversionError` if the context lacks the data the conversion needs.
    public var trueAltitude: Measurement<UnitLength> {
        get throws(AltitudeConversionError) { try value(in: .trueAltitude) }
    }

    /// Geopotential altitude (accounting for gravity variation with height)
    /// Geopotential altitude uses a constant gravity model (g₀ = 9.80665 m/s²).
    /// This is the altitude reference used internally by the ISA standard atmosphere.
    /// - Note: This conversion requires true altitude, which in turn requires a temperature profile.
    /// - Throws: `AltitudeConversionError` if the context lacks the data the conversion needs.
    public var geopotential: Measurement<UnitLength> {
        get throws(AltitudeConversionError) { try value(in: .geopotential) }
    }

    // MARK: - Geopotential Conversion

    /// Convert geopotential altitude to true altitude (geometric)
    /// Formula: h = (r × H) / (r - H)
    /// where r = Earth's mean radius, H = geopotential altitude
    internal func convertGeopotentialToTrueAltitude() -> Measurement<UnitLength> {
        let r = ISA.earthMeanRadius.meters
        let H = value.meters

        // h = (r × H) / (r - H)
        let h = (r * H) / (r - H)
        return .init(meters: h)
    }
}
