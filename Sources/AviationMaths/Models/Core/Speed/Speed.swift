import Foundation

/// Represents an airspeed with automatic conversions between different reference frames.
///
/// Similar to `Altitude`, this type stores a speed value in one reference frame and
/// provides computed properties to convert to other reference frames on demand.
///
/// ## Speed References
/// - **CAS** (Calibrated Airspeed): Corrected instrument reading at sea level equivalent
/// - **EAS** (Equivalent Airspeed): CAS corrected for compressibility
/// - **TAS** (True Airspeed): Actual speed through the air mass
/// - **Mach**: Ratio of TAS to local speed of sound
///
/// ## Conversion Chain
/// ```
/// CAS ↔ EAS (via compressibility correction, needs altitude)
///       ↓
///      TAS (via density correction, needs density/temperature)
///       ↓
///     Mach (via speed of sound, needs temperature)
/// ```
///
/// ## Usage Example
/// ```swift
/// let context = SpeedContext(
///     pressureAltitude: .init(feet: 10000),
///     deltaISA: .init(kelvin: 0)
/// )
///
/// let speed = Speed(
///     knots: 250,
///     reference: .calibratedAirspeed,
///     context: context
/// )
///
/// print(speed.tas.knots)  // True airspeed in knots
/// print(speed.mach)       // Mach number
/// ```
public struct Speed: Sendable {
    public let value: Measurement<UnitSpeed>
    public let reference: SpeedReference
    public let context: SpeedContext
    
    /// For Mach number reference, store as dimensionless value
    public let machValue: Double?
    
    // MARK: - Initializers
    
    public init(value: Measurement<UnitSpeed>, reference: SpeedReference, context: SpeedContext) {
        precondition(reference != .machNumber, "Use init(mach:context:) for Mach number")
        self.value = value
        self.reference = reference
        self.context = context
        self.machValue = nil
    }
    
    public init(mach: Double, context: SpeedContext) {
        self.machValue = mach
        self.reference = .machNumber
        self.context = context
        // Value is computed from mach
        self.value = .init(mps: 0)  // Placeholder, use computed properties
    }
    
    // MARK: - Convenience Initializers
    
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
    
    /// Calibrated Airspeed
    public var cas: Measurement<UnitSpeed> {
        reference == .calibratedAirspeed ? value : convertToCAS()
    }
    
    /// Equivalent Airspeed
    public var eas: Measurement<UnitSpeed> {
        reference == .equivalentAirspeed ? value : convertToEAS()
    }
    
    /// True Airspeed
    public var tas: Measurement<UnitSpeed> {
        reference == .trueAirspeed ? value : convertToTAS()
    }
    
    /// Mach Number (dimensionless)
    public var mach: Double {
        reference == .machNumber ? machValue! : convertToMach()
    }
    
    // MARK: - Conversion Methods
    
    private func convertToCAS() -> Measurement<UnitSpeed> {
        guard let delta = context.relativePressure else {
            preconditionFailure("Pressure altitude required for CAS conversion")
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
            // TAS → EAS → CAS
            return convertToEAS().asCAS(context: context)
            
        case .machNumber:
            // Mach → TAS → EAS → CAS
            return convertToTAS().asCAS(context: context)
        }
    }
    
    private func convertToEAS() -> Measurement<UnitSpeed> {
        guard let delta = context.relativePressure else {
            preconditionFailure("Pressure altitude required for EAS conversion")
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
                preconditionFailure("Density/temperature required for EAS conversion from TAS")
            }
            return AirDataEquations.equivalentAirspeed(
                fromTrueAirspeed: value,
                density: density
            )
            
        case .machNumber:
            // Mach → TAS → EAS
            return convertToTAS().asEAS(context: context)
        }
    }
    
    private func convertToTAS() -> Measurement<UnitSpeed> {
        guard let density = context.density else {
            preconditionFailure("Density/temperature required for TAS conversion")
        }
        
        switch reference {
        case .calibratedAirspeed, .equivalentAirspeed:
            // Go through EAS first
            let easValue = reference == .equivalentAirspeed ? value : convertToEAS()
            return AirDataEquations.trueAirspeed(
                fromEquivalentAirspeed: easValue,
                density: density
            )
            
        case .trueAirspeed:
            return value
            
        case .machNumber:
            guard let speedOfSound = context.speedOfSound else {
                preconditionFailure("Temperature required for TAS conversion from Mach")
            }
            return AirDataEquations.trueAirspeed(
                fromMachNumber: machValue!,
                speedOfSound: speedOfSound
            )
        }
    }
    
    private func convertToMach() -> Double {
        guard let speedOfSound = context.speedOfSound else {
            preconditionFailure("Temperature required for Mach conversion")
        }
        
        // All conversions go through TAS
        let tasValue = reference == .trueAirspeed ? value : convertToTAS()
        return AirDataEquations.machNumber(
            fromTrueAirspeed: tasValue,
            speedOfSound: speedOfSound
        )
    }
}

// MARK: - Helper Extensions

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

// MARK: - Convenience Conversion Method

extension Speed {
    /// Create a new Speed in a different reference frame
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

// MARK: - Equatable & Hashable

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

// MARK: - Comparable

extension Speed: Comparable {
    public static func < (lhs: Speed, rhs: Speed) -> Bool {
        return lhs.tas.mps < rhs.tas.mps
    }
}
