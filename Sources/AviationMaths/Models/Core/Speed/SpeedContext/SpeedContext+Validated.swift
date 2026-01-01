import Foundation

// MARK: - ValidatedSpeedContext

/// A validated speed context that guarantees all speed conversions will work.
///
/// This wrapper ensures the underlying `SpeedContext` has all required data
/// for CAS ↔ EAS ↔ TAS ↔ Mach conversions.
public struct ValidatedSpeedContext: Sendable, Equatable, Codable {
    
    public let raw: SpeedContext
    public let density: Measurement<UnitConcentrationMass>
    public let speedOfSound: Measurement<UnitSpeed>
    public let relativePressure: Double
    public let pressureAltitude: Measurement<UnitLength>
    
    // MARK: - Initializers
    
    /// Creates a validated speed context, throwing if data is incomplete.
    public init(_ context: SpeedContext) throws {
        guard let pa = context.pressureAltitude else {
            throw ValidationError.missingPressureAltitude
        }
        guard let density = context.density else {
            throw ValidationError.missingDensity
        }
        guard let sos = context.speedOfSound else {
            throw ValidationError.missingSpeedOfSound
        }
        guard let delta = context.relativePressure else {
            throw ValidationError.missingRelativePressure
        }
        
        // Check for NaN/Infinity
        guard density.value.isFinite else {
            throw ValidationError.invalidValue("density", density.value)
        }
        guard sos.value.isFinite else {
            throw ValidationError.invalidValue("speedOfSound", sos.value)
        }
        guard delta.isFinite else {
            throw ValidationError.invalidValue("relativePressure", delta)
        }
        
        self.raw = context
        self.pressureAltitude = pa
        self.density = density
        self.speedOfSound = sos
        self.relativePressure = delta
    }
    
    /// Creates a validated context from a validated altitude.
    ///
    /// This is the recommended way to create a speed context in BallisticMaths.
    public init(at altitude: ValidatedAltitude) throws {
        let context = SpeedContext.at(altitude: altitude.raw)
        try self.init(context)
    }
    
    // MARK: - Factory Methods
    
    /// Standard ISA conditions at sea level - always valid.
    public static let standardISA: ValidatedSpeedContext = {
        // This cannot fail - standardISA is always complete
        try! ValidatedSpeedContext(SpeedContext.standardISA)
    }()
    
    /// Creates a validated context from QNH and AMSL with measured temperature.
    public static func fromQNHAndAMSL(
        qnh: Measurement<UnitPressure>,
        amsl: Measurement<UnitLength>,
        measuredTemperature: Measurement<UnitTemperature>
    ) throws -> ValidatedSpeedContext {
        let context = SpeedContext.fromQNHAndAMSL(
            qnh: qnh,
            amsl: amsl,
            measuredTemperature: measuredTemperature
        )
        return try ValidatedSpeedContext(context)
    }
    
    // MARK: - Errors
    
    public enum ValidationError: Error, LocalizedError, Sendable {
        case missingPressureAltitude
        case missingDensity
        case missingSpeedOfSound
        case missingRelativePressure
        case invalidValue(String, Double)
        
        public var errorDescription: String? {
            switch self {
            case .missingPressureAltitude:
                return "SpeedContext missing pressure altitude"
            case .missingDensity:
                return "SpeedContext missing density (requires pressure altitude)"
            case .missingSpeedOfSound:
                return "SpeedContext missing speed of sound (requires temperature)"
            case .missingRelativePressure:
                return "SpeedContext missing relative pressure"
            case .invalidValue(let name, let value):
                return "SpeedContext has invalid \(name): \(value)"
            }
        }
    }
}

extension SpeedContext {
    /// Attempts to create a validated version of this context.
    public var validated: ValidatedSpeedContext? {
        try? ValidatedSpeedContext(self)
    }
    
    /// Creates a validated version, throwing on failure.
    public func asValidated() throws -> ValidatedSpeedContext {
        try ValidatedSpeedContext(self)
    }
}
