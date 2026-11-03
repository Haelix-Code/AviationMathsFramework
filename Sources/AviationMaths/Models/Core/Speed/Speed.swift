import Foundation

public struct Speed: Sendable {
    public let value: Measurement<UnitSpeed>
    public let reference: SpeedReference
    public let context: SpeedContext
    internal let machValue: Double?

    public init(value: Measurement<UnitSpeed>, reference: SpeedReference, context: SpeedContext) {
        if reference == .machNumber {
            self.machValue = value.value
            self.reference = .machNumber
            self.context = context
            self.value = .init(mps: 0)
        } else {
            self.value = value
            self.reference = reference
            self.context = context
            self.machValue = nil
        }
    }

    public init(mach: Double, context: SpeedContext) {
        self.machValue = mach
        self.reference = .machNumber
        self.context = context
        self.value = .init(mps: 0)
    }

    public init(mps: Double, reference: SpeedReference, context: SpeedContext) {
        if reference == .machNumber {
            self.init(mach: mps, context: context)
        } else {
            self.init(value: .init(mps: mps), reference: reference, context: context)
        }
    }

    public init(knots: Double, reference: SpeedReference, context: SpeedContext) {
        if reference == .machNumber {
            self.init(mach: knots, context: context)
        } else {
            self.init(value: .init(knots: knots), reference: reference, context: context)
        }
    }

    public init(fps: Double, reference: SpeedReference, context: SpeedContext) {
        if reference == .machNumber {
            self.init(mach: fps, context: context)
        } else {
            self.init(value: .init(fps: fps), reference: reference, context: context)
        }
    }

    // MARK: - Computed Properties for Each Reference

    /// Calibrated airspeed. Use `try?` for an optional result.
    /// - Throws: `SpeedConversionError` if the context lacks the data the conversion needs.
    public var cas: Measurement<UnitSpeed> {
        get throws(SpeedConversionError) { try convertToCAS() }
    }

    /// Equivalent airspeed. Use `try?` for an optional result.
    /// - Throws: `SpeedConversionError` if the context lacks the data the conversion needs.
    public var eas: Measurement<UnitSpeed> {
        get throws(SpeedConversionError) { try convertToEAS() }
    }

    /// True airspeed. Use `try?` for an optional result.
    /// - Throws: `SpeedConversionError` if the context lacks the data the conversion needs.
    public var tas: Measurement<UnitSpeed> {
        get throws(SpeedConversionError) { try convertToTAS() }
    }

    /// Mach number. Use `try?` for an optional result.
    /// - Throws: `SpeedConversionError` if the context lacks the data the conversion needs.
    public var mach: Double {
        get throws(SpeedConversionError) { try convertToMach() }
    }

    internal func convertToCAS() throws(SpeedConversionError) -> Measurement<UnitSpeed> {
        switch reference {
        case .calibratedAirspeed:
            return value

        case .equivalentAirspeed:
            let delta = try context.relativePressure
            return AirDataEquations.calibratedAirspeed(
                fromEquivalentAirspeed: value,
                relativePressure: delta
            )

        case .trueAirspeed:
            let eas = try convertToEAS()
            return try Speed(value: eas, reference: .equivalentAirspeed, context: context)
                .convertToCAS()

        case .machNumber:
            let tas = try convertToTAS()
            return try Speed(value: tas, reference: .trueAirspeed, context: context)
                .convertToCAS()
        }
    }

    internal func convertToEAS() throws(SpeedConversionError) -> Measurement<UnitSpeed> {
        switch reference {
        case .calibratedAirspeed:
            let delta = try context.relativePressure
            return AirDataEquations.equivalentAirspeed(
                fromCalibratedAirspeed: value,
                relativePressure: delta
            )

        case .equivalentAirspeed:
            return value

        case .trueAirspeed:
            let density = try context.density
            return AirDataEquations.equivalentAirspeed(
                fromTrueAirspeed: value,
                density: density
            )

        case .machNumber:
            let tas = try convertToTAS()
            return try Speed(value: tas, reference: .trueAirspeed, context: context)
                .convertToEAS()
        }
    }

    internal func convertToTAS() throws(SpeedConversionError) -> Measurement<UnitSpeed> {
        switch reference {
        case .calibratedAirspeed, .equivalentAirspeed:
            let density = try context.density
            let easValue = reference == .equivalentAirspeed ? value : try convertToEAS()
            return AirDataEquations.trueAirspeed(
                fromEquivalentAirspeed: easValue,
                density: density
            )

        case .trueAirspeed:
            return value

        case .machNumber:
            let speedOfSound = try context.speedOfSound
            return AirDataEquations.trueAirspeed(
                fromMachNumber: machValue!,
                speedOfSound: speedOfSound
            )
        }
    }

    internal func convertToMach() throws(SpeedConversionError) -> Double {
        switch reference {
        case .machNumber:
            return machValue!
        case .calibratedAirspeed:
            let delta = try context.relativePressure
            return AirDataEquations.machNumber(fromCalibratedAirspeed: value, relativePressure: delta)
        case .equivalentAirspeed, .trueAirspeed:
            break
        }

        let speedOfSound = try context.speedOfSound
        let tasValue = reference == .trueAirspeed ? value : try convertToTAS()
        return AirDataEquations.machNumber(
            fromTrueAirspeed: tasValue,
            speedOfSound: speedOfSound
        )
    }
}

extension Speed {
    /// This speed in another reference, in the same context.
    /// - Throws: `SpeedConversionError` if the context lacks the data the conversion needs.
    public func converted(to newReference: SpeedReference) throws(SpeedConversionError) -> Speed {
        switch newReference {
        case .calibratedAirspeed:
            return Speed(value: try cas, reference: .calibratedAirspeed, context: context)
        case .equivalentAirspeed:
            return Speed(value: try eas, reference: .equivalentAirspeed, context: context)
        case .trueAirspeed:
            return Speed(value: try tas, reference: .trueAirspeed, context: context)
        case .machNumber:
            return Speed(mach: try mach, context: context)
        }
    }
}

// `==` and `hash(into:)` are synthesized: they compare the stored value, reference and
// context, never convert, and so can't trap.
extension Speed: Hashable {}

// MARK: - Speed Comparison

// These compare the physical speed (TAS).
extension Speed {
    /// Whether both speeds are the same, compared as TAS within `tolerance`.
    /// - Throws: `SpeedConversionError` if either speed can't be converted to TAS.
    public func isSameSpeed(
        as other: Speed,
        tolerance: Measurement<UnitSpeed>
    ) throws(SpeedConversionError) -> Bool {
        let difference = try tas.mps - other.tas.mps
        return abs(difference) <= tolerance.mps
    }

    /// Whether this speed is slower than `other`, compared as TAS.
    /// - Throws: `SpeedConversionError` if either speed can't be converted to TAS.
    public func isSlower(than other: Speed) throws(SpeedConversionError) -> Bool {
        try tas.mps < other.tas.mps
    }
}
