import Foundation

// MARK: - ValidatedAltitude

/// A type-safe wrapper around `Altitude` that guarantees all conversions are safe.
public struct ValidatedAltitude: Sendable, Equatable {

    public let raw: Altitude
    public let validatedContext: ValidatedAltitudeContext

    // MARK: - Initializers

    /// - Throws: `AltitudeConversionError` if the altitude's context is incomplete
    ///   (see `ValidatedAltitudeContext.init(_:)`).
    public init(_ altitude: Altitude) throws(AltitudeConversionError) {
        self.validatedContext = try ValidatedAltitudeContext(altitude.context)
        self.raw = altitude
    }

    public init(
        value: Measurement<UnitLength>,
        reference: VerticalReference,
        context: ValidatedAltitudeContext
    ) {
        self.validatedContext = context
        self.raw = Altitude(value: value, reference: reference, context: context.raw)
    }

    // MARK: - Accessors (No `try`: the validated context has everything a conversion needs)

    public var agl: Measurement<UnitLength> { value(in: .agl) }
    public var amsl: Measurement<UnitLength> { value(in: .amsl) }
    public var pressureAltitude: Measurement<UnitLength> { value(in: .pressureAltitude) }
    public var trueAltitude: Measurement<UnitLength> { value(in: .trueAltitude) }
    public var geopotential: Measurement<UnitLength> { value(in: .geopotential) }

    public var reference: VerticalReference { raw.reference }
    public var value: Measurement<UnitLength> { raw.value }
    public var context: AltitudeContext { raw.context }

    // MARK: - Conversion

    public func value(in reference: VerticalReference) -> Measurement<UnitLength> {
        do {
            return try raw.value(in: reference)
        } catch {
            // Unreachable: ValidatedAltitudeContext guarantees ground elevation, QNH and a
            // temperature profile, which is everything any conversion needs.
            preconditionFailure("Validated altitude couldn't convert to \(reference): \(error)")
        }
    }

    public func converted(to reference: VerticalReference) -> ValidatedAltitude {
        ValidatedAltitude(
            value: value(in: reference),
            reference: reference,
            context: validatedContext
        )
    }
}

// MARK: - Level Comparison

extension ValidatedAltitude {
    /// Whether both altitudes are at the same level, compared as AMSL within `tolerance`.
    public func isSameLevel(as other: ValidatedAltitude, tolerance: Measurement<UnitLength>) -> Bool {
        abs(amsl.meters - other.amsl.meters) <= tolerance.meters
    }

    /// Whether this altitude is below `other`, compared as AMSL.
    public func isBelow(_ other: ValidatedAltitude) -> Bool {
        amsl.meters < other.amsl.meters
    }
}

// MARK: - Altitude Extension

extension Altitude {
    public var validated: ValidatedAltitude? {
        try? ValidatedAltitude(self)
    }
}
