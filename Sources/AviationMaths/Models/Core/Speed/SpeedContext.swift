import Foundation

public struct SpeedContext: Sendable {
    public let pressureAltitude: Measurement<UnitLength>?
    public let temperature: Measurement<UnitTemperature>?
    public let deltaISA: Measurement<UnitTemperature>?

    private let _density: Measurement<UnitConcentrationMass>?
    private let measuredPressureOverride: Measurement<UnitPressure>?

    public var density: Measurement<UnitConcentrationMass>? {
        // Return directly if explicitly set
        if let density = _density {
            return density
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

    private func resolveTemperature(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature> {
        if let explicitTemp = temperature {
            return explicitTemp
        }

        let deviation = deltaISA ?? .init(kelvin: 0)
        return ISA.temperature(at: altitude, deltaISA: deviation)
    }

    public var speedOfSound: Measurement<UnitSpeed>? {
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
