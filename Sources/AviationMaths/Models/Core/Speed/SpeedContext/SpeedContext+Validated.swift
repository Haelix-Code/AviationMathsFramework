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
    public init(_ context: SpeedContext) throws(ValidationError) {
        // The pressure altitude is every derived value's fallback, so with it none of them can
        // be missing.
        guard let pa = context.pressureAltitude,
              let density = try? context.density,
              let sos = try? context.speedOfSound,
              let delta = try? context.relativePressure else {
            throw .missingPressureAltitude
        }

        guard density.value.isFinite else { throw .nonFinite(.density) }
        guard sos.value.isFinite else { throw .nonFinite(.speedOfSound) }
        guard delta.isFinite else { throw .nonFinite(.relativePressure) }

        self.raw = context
        self.pressureAltitude = pa
        self.density = density
        self.speedOfSound = sos
        self.relativePressure = delta
    }

    /// Creates a validated context from a validated altitude.
    ///
    /// This is the recommended way to create a speed context in BallisticMaths.
    public init(at altitude: ValidatedAltitude) throws(ValidationError) {
        let context = SpeedContext.at(altitude: altitude.raw)
        try self.init(context)
    }

    // MARK: - Factory Methods

    /// Standard ISA conditions at sea level - always valid.
    public static let standardISA: ValidatedSpeedContext = {
        do {
            return try ValidatedSpeedContext(SpeedContext.standardISA)
        } catch {
            // Unreachable: SpeedContext.standardISA has a pressure altitude, temperature and density.
            preconditionFailure("SpeedContext.standardISA failed validation: \(error)")
        }
    }()

    /// Decoding re-validates `raw`, so a decoded context keeps the guarantee that every
    /// conversion succeeds.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let raw = try container.decode(SpeedContext.self, forKey: .raw)
        do {
            try self.init(raw)
        } catch {
            throw DecodingError.dataCorruptedError(
                forKey: .raw,
                in: container,
                debugDescription: "Context isn't complete: \(error)"
            )
        }
    }

    /// Creates a validated context from QNH and AMSL with measured temperature.
    public static func fromQNHAndAMSL(
        qnh: Measurement<UnitPressure>,
        amsl: Measurement<UnitLength>,
        measuredTemperature: Measurement<UnitTemperature>
    ) throws(ValidationError) -> ValidatedSpeedContext {
        let context = SpeedContext.fromQNHAndAMSL(
            qnh: qnh,
            amsl: amsl,
            measuredTemperature: measuredTemperature
        )
        return try ValidatedSpeedContext(context)
    }

    // MARK: - Errors

    /// A value validation derives from the context.
    public enum Quantity: Equatable, Sendable {
        case density
        case speedOfSound
        case relativePressure
    }

    public enum ValidationError: Error, Equatable, Sendable, LocalizedError {
        case missingPressureAltitude
        /// A derived value is NaN or infinite, e.g. from a NaN pressure altitude.
        case nonFinite(Quantity)

        public var errorDescription: String? {
            switch self {
            case .missingPressureAltitude:
                return "SpeedContext missing pressure altitude"
            case .nonFinite(let quantity):
                return "SpeedContext's \(quantity) isn't a finite number"
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
    public func asValidated() throws(ValidatedSpeedContext.ValidationError) -> ValidatedSpeedContext {
        try ValidatedSpeedContext(self)
    }
}
