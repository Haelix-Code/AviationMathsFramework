import Foundation

public struct SpeedContext: Sendable, Equatable, Codable {
    public let pressureAltitude: Measurement<UnitLength>?
    public let temperature: Measurement<UnitTemperature>?
    public let deltaISA: Measurement<UnitTemperature>?

    private let _density: Measurement<UnitConcentrationMass>?
    private let measuredPressureOverride: Measurement<UnitPressure>?

    // MARK: - Optional Computed Properties
    
    public var density: Measurement<UnitConcentrationMass>? {
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
            return nil
        }

        let pressure = ISA.pressure(at: altitude, deltaISA: .init(kelvin: 0))
        let effectiveTemperature = resolveTemperature(at: altitude)

        return ISA.densityFromPressureAndTemperature(
            pressure: pressure,
            temperature: effectiveTemperature
        )
    }

    public var speedOfSound: Measurement<UnitSpeed>? {
        if let explicitTemp = temperature {
            return ISA.speedOfSoundFromTemperature(temperature: explicitTemp)
        }

        guard let altitude = pressureAltitude else {
            return nil
        }

        let effectiveTemperature = resolveTemperature(at: altitude)
        return ISA.speedOfSoundFromTemperature(temperature: effectiveTemperature)
    }

    public var relativePressure: Double? {
        if let measuredPressure = measuredPressureOverride {
            return measuredPressure.pascals / ISA.seaLevelPressure.pascals
        }

        guard let altitude = pressureAltitude else {
            return nil
        }

        let atmosphericPressure = ISA.pressure(at: altitude, deltaISA: .init(kelvin: 0))
        return atmosphericPressure.pascals / ISA.seaLevelPressure.pascals
    }

    // MARK: - Throwing Computed Properties
    
    /// Returns density, throwing an error if it cannot be calculated
    /// - Throws: `ContextCalculationError.insufficientData` if required data is missing
    /// - Returns: Air density
    public func densityThrowing() throws -> Measurement<UnitConcentrationMass> {
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

    /// Returns speed of sound, throwing an error if it cannot be calculated
    /// - Throws: `ContextCalculationError.insufficientData` if required data is missing
    /// - Returns: Speed of sound
    public func speedOfSoundThrowing() throws -> Measurement<UnitSpeed> {
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
    
    /// Returns relative pressure, throwing an error if it cannot be calculated
    /// - Throws: `ContextCalculationError.insufficientData` if required data is missing
    /// - Returns: Relative pressure (delta)
    public func relativePressureThrowing() throws -> Double {
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

