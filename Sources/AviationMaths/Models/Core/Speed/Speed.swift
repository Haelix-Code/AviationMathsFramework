import Foundation

public struct Speed: Sendable {
    public let value: Measurement<UnitSpeed>
    public let reference: SpeedReference
    public let context: SpeedContext
    public let machValue: Double?

    private var localSpeedOfSound: Double? {
        guard let s = context.speedOfSound else {
            return nil
        }
        return s.mps
    }

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

    // CAS - will crash if context is insufficient
    /// - Warning: Use `casIfPossible` or `asCAS()` for safer alternatives
    public var cas: Measurement<UnitSpeed> {
        reference == .calibratedAirspeed ? value : try! convertToCAS()
    }

    /// EAS - will crash if context is insufficient
    /// - Warning: Use `easIfPossible` or `asEAS()` for safer alternatives
    public var eas: Measurement<UnitSpeed> {
        reference == .equivalentAirspeed ? value : try! convertToEAS()
    }

    /// TAS - will crash if context is insufficient
    /// - Warning: Use `tasIfPossible` or `asTAS()` for safer alternatives
    public var tas: Measurement<UnitSpeed> {
        reference == .trueAirspeed ? value : try! convertToTAS()
    }

    /// Mach - will crash if context is insufficient
    /// - Warning: Use `machIfPossible` or `asMach()` for safer alternatives
    public var mach: Double {
        reference == .machNumber ? machValue! : try! convertToMach()
    }

    internal func convertToCAS() throws -> Measurement<UnitSpeed> {
        guard let delta = context.relativePressure else {
            throw SpeedConversionError.missingPressureAltitude
        }

        switch reference {
        case .calibratedAirspeed:
            return value

        case .equivalentAirspeed:
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

    internal func convertToEAS() throws -> Measurement<UnitSpeed> {
        guard let delta = context.relativePressure else {
            throw SpeedConversionError.missingPressureAltitude
        }

        switch reference {
        case .calibratedAirspeed:
            return AirDataEquations.equivalentAirspeed(
                fromCalibratedAirspeed: value,
                relativePressure: delta
            )

        case .equivalentAirspeed:
            return value

        case .trueAirspeed:
            guard let density = context.density else {
                throw SpeedConversionError.missingDensity
            }
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

    internal func convertToTAS() throws -> Measurement<UnitSpeed> {
        guard let density = context.density else {
            throw SpeedConversionError.missingDensity
        }

        switch reference {
        case .calibratedAirspeed, .equivalentAirspeed:
            let easValue = reference == .equivalentAirspeed ? value : try convertToEAS()
            return AirDataEquations.trueAirspeed(
                fromEquivalentAirspeed: easValue,
                density: density
            )

        case .trueAirspeed:
            return value

        case .machNumber:
            guard let speedOfSound = context.speedOfSound else {
                throw SpeedConversionError.missingTemperature
            }
            return AirDataEquations.trueAirspeed(
                fromMachNumber: machValue!,
                speedOfSound: speedOfSound
            )
        }
    }

    internal func convertToMach() throws -> Double {
        guard let speedOfSound = context.speedOfSound else {
            throw SpeedConversionError.missingTemperature
        }

        let tasValue = reference == .trueAirspeed ? value : try convertToTAS()
        return AirDataEquations.machNumber(
            fromTrueAirspeed: tasValue,
            speedOfSound: speedOfSound
        )
    }
}

private extension Measurement<UnitSpeed> {
    func asCAS(context: SpeedContext) -> Measurement<UnitSpeed> {
        let speed = Speed(value: self, reference: .equivalentAirspeed, context: context)
        return speed.cas
    }

    func asEAS(context: SpeedContext) -> Measurement<UnitSpeed> {
        let speed = Speed(value: self, reference: .trueAirspeed, context: context)
        return speed.eas
    }
}

extension Speed {
    public func `in`(_ newReference: SpeedReference) -> Speed {
        switch newReference {
        case .calibratedAirspeed:
            return Speed(value: cas, reference: .calibratedAirspeed, context: context)
        case .equivalentAirspeed:
            return Speed(value: eas, reference: .equivalentAirspeed, context: context)
        case .trueAirspeed:
            return Speed(value: tas, reference: .trueAirspeed, context: context)
        case .machNumber:
            return Speed(mach: mach, context: context)
        }
    }
}

extension Speed: Equatable {
    public static func == (lhs: Speed, rhs: Speed) -> Bool {
        // Compare as TAS (the fundamental speed through air)
        return lhs.tas.mps == rhs.tas.mps
    }
}

extension Speed: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tas.mps)
    }
}

extension Speed: Comparable {
    public static func < (lhs: Speed, rhs: Speed) -> Bool {
        return lhs.tas.mps < rhs.tas.mps
    }
}
