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

    /// Above ground level altitude
   /// - Warning: This computed property uses `try!` and will crash if context lacks ground elevation.
   ///   For error handling use `try value(in: .agl)`, or `try? value(in: .agl)` for optional return.
   public var agl: Measurement<UnitLength> {
       // swiftlint:disable:next force_try
       reference == .agl ? value : try! convertToAGLThrowing()
   }

   /// Above mean sea level altitude
   /// - Warning: This computed property uses `try!` and will crash if context is insufficient.
   ///   For error handling use `try value(in: .amsl)`, or `try? value(in: .amsl)` for optional return.
   public var amsl: Measurement<UnitLength> {
       // swiftlint:disable:next force_try
       reference == .amsl ? value : try! convertToAMSLThrowing()
   }

   /// Pressure altitude
   /// - Warning: This computed property uses `try!` and will crash if context lacks QNH.
   ///   For error handling use `try value(in: .pressureAltitude)`, or `try? value(in: .pressureAltitude)`
   ///   for optional return.
   public var pressureAltitude: Measurement<UnitLength> {
       // swiftlint:disable:next force_try
       reference == .pressureAltitude ? value : try! convertToPressureAltitudeThrowing()
   }

   /// True altitude
   /// - Warning: This computed property uses `try!` and will crash if context lacks temperature profile.
   ///   For error handling use `try value(in: .trueAltitude)`, or `try? value(in: .trueAltitude)` for optional return.
   public var trueAltitude: Measurement<UnitLength> {
       // swiftlint:disable:next force_try
       reference == .trueAltitude ? value : try! convertToTrueAltitudeThrowing()
   }

   /// Geopotential altitude (accounting for gravity variation with height)
   /// Geopotential altitude uses a constant gravity model (g₀ = 9.80665 m/s²).
   /// This is the altitude reference used internally by the ISA standard atmosphere.
   /// - Note: This conversion requires true altitude, which in turn requires a temperature profile.
   /// - Warning: This computed property uses `try!` and will crash if context lacks temperature profile.
   ///   For error handling use `try value(in: .geopotential)`, or `try? value(in: .geopotential)` for optional return.
   public var geopotential: Measurement<UnitLength> {
       // swiftlint:disable:next force_try
       reference == .geopotential ? value : try! convertToGeopotentialThrowing()
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

// MARK: - Convenience Properties

extension Altitude {
    /// Create a new Altitude in a different reference frame.
    /// Returns nil if the conversion is not possible with the current context.
    public func `in`(_ newReference: VerticalReference) -> Altitude? {
        guard canConvert(to: newReference) else { return nil }

        let newValue: Measurement<UnitLength>
        switch newReference {
        case .agl: newValue = agl
        case .amsl: newValue = amsl
        case .pressureAltitude: newValue = pressureAltitude
        case .trueAltitude: newValue = trueAltitude
        case .geopotential: newValue = geopotential
        }
        return Altitude(value: newValue, reference: newReference, context: context)
    }

    /// Create a new Altitude in a different reference frame.
    /// Crashes if the conversion is not possible.
    public func converted(to newReference: VerticalReference) -> Altitude {
        guard let result = self.in(newReference) else {
            preconditionFailure("Cannot convert from \(reference) to \(newReference) with current context")
        }
        return result
    }
}
