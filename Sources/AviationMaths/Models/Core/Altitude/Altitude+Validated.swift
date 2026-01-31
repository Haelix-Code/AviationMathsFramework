import Foundation

// MARK: - ValidatedAltitude

/// A type-safe wrapper around `Altitude` that guarantees all conversions are safe.
public struct ValidatedAltitude: Sendable, Equatable {
    
    public let raw: Altitude
    public let validatedContext: ValidatedAltitudeContext
    
    // MARK: - Initializers
    
    public init(_ altitude: Altitude) {
        self.validatedContext = ValidatedAltitudeContext(altitude.context)
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
    
    // MARK: - Safe Accessors (Guaranteed Non-Crashing)

    public var agl: Measurement<UnitLength> { raw.agl }
    public var amsl: Measurement<UnitLength> { raw.amsl }
    public var pressureAltitude: Measurement<UnitLength> { raw.pressureAltitude }
    public var trueAltitude: Measurement<UnitLength> { raw.trueAltitude }
    public var geopotential: Measurement<UnitLength> { raw.geopotential }

    public var reference: VerticalReference { raw.reference }
    public var value: Measurement<UnitLength> { raw.value }
    public var context: AltitudeContext { raw.context }

    // MARK: - Conversion

    public func value(in reference: VerticalReference) -> Measurement<UnitLength> {
        switch reference {
        case .agl: return raw.agl
        case .amsl: return raw.amsl
        case .pressureAltitude: return raw.pressureAltitude
        case .trueAltitude: return raw.trueAltitude
        case .geopotential: return raw.geopotential
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

// MARK: - Comparable

extension ValidatedAltitude: Comparable {
    public static func < (lhs: ValidatedAltitude, rhs: ValidatedAltitude) -> Bool {
        lhs.amsl.converted(to: .meters).value < rhs.amsl.converted(to: .meters).value
    }
}

// MARK: - Altitude Extension

extension Altitude {
    public var validated: ValidatedAltitude? {
        guard context.isComplete else { return nil }
        return ValidatedAltitude(self)
    }
}
