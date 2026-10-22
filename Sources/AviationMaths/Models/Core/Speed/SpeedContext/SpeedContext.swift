import Foundation

public struct SpeedContext: Sendable, Hashable, Codable {
    public let pressureAltitude: Measurement<UnitLength>?
    public let temperature: Measurement<UnitTemperature>?
    public let deltaISA: Measurement<UnitTemperature>?

    private let _density: Measurement<UnitConcentrationMass>?
    private let measuredPressureOverride: Measurement<UnitPressure>?

    // MARK: - Derived Values (use `try?` for an optional result)

    /// Air density: the one given, or from pressure and temperature
    /// - Throws: `ContextCalculationError.insufficientData` if required data is missing
    public var density: Measurement<UnitConcentrationMass> {
        get throws(ContextCalculationError) {
            if let density = _density {
                return density
            }

            if let measuredPressure = measuredPressureOverride, let explicitTemp = temperature {
                return ISA.densityFromPressureAndTemperature(
                    pressure: measuredPressure,
                    temperature: explicitTemp
                )
            }

            guard let altitude = pressureAltitude else {
                throw ContextCalculationError.insufficientData(
                    calculation: "density",
                    missing: ["pressureAltitude"]
                )
            }

            let pressure = ISA.pressure(at: altitude, deltaISA: .init(kelvin: 0))
            let effectiveTemperature = resolveTemperature(at: altitude)

            return ISA.densityFromPressureAndTemperature(
                pressure: pressure,
                temperature: effectiveTemperature
            )
        }
    }

    /// Speed of sound: from the temperature given, or the ISA temperature at the pressure altitude
    /// - Throws: `ContextCalculationError.insufficientData` if required data is missing
    public var speedOfSound: Measurement<UnitSpeed> {
        get throws(ContextCalculationError) {
            if let explicitTemp = temperature {
                return ISA.speedOfSoundFromTemperature(temperature: explicitTemp)
            }

            guard let altitude = pressureAltitude else {
                throw ContextCalculationError.insufficientData(
                    calculation: "speedOfSound",
                    missing: ["pressureAltitude"]
                )
            }

            let effectiveTemperature = resolveTemperature(at: altitude)
            return ISA.speedOfSoundFromTemperature(temperature: effectiveTemperature)
        }
    }

    /// Relative pressure δ = p/p₀: from the pressure given, or ISA pressure at the pressure altitude
    /// - Throws: `ContextCalculationError.insufficientData` if required data is missing
    public var relativePressure: Double {
        get throws(ContextCalculationError) {
            if let measuredPressure = measuredPressureOverride {
                return measuredPressure.pascals / ISA.seaLevelPressure.pascals
            }

            guard let altitude = pressureAltitude else {
                throw ContextCalculationError.insufficientData(
                    calculation: "relativePressure",
                    missing: ["pressureAltitude"]
                )
            }

            let atmosphericPressure = ISA.pressure(at: altitude, deltaISA: .init(kelvin: 0))
            return atmosphericPressure.pascals / ISA.seaLevelPressure.pascals
        }
    }

    // MARK: - Private Helpers

    private func resolveTemperature(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature> {
        if let explicitTemp = temperature {
            return explicitTemp
        }

        let deviation = deltaISA ?? .init(kelvin: 0)
        return ISA.temperature(at: altitude, deltaISA: deviation)
    }

    // MARK: - Initializers

    public init(
        pressureAltitude: Measurement<UnitLength>? = nil,
        temperature: Measurement<UnitTemperature>? = nil,
        deltaISA: Measurement<UnitTemperature>? = nil,
        density: Measurement<UnitConcentrationMass>? = nil,
        measuredPressure: Measurement<UnitPressure>? = nil
    ) {
        self.pressureAltitude = pressureAltitude
        self.temperature = temperature
        self.deltaISA = deltaISA
        self._density = density
        self.measuredPressureOverride = measuredPressure
    }

    public static let standardISA = SpeedContext(
        pressureAltitude: .surface,
        temperature: ISA.seaLevelTemperature,
        deltaISA: .init(kelvin: 0),
        density: ISA.seaLevelDensity
    )
}
