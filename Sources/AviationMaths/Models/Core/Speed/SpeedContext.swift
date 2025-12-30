import Foundation

public struct SpeedContext: Sendable {
    public let pressureAltitude: Measurement<UnitLength>?
    public let temperature: Measurement<UnitTemperature>?
    public let deltaISA: Measurement<UnitTemperature>?

    private let _density: Measurement<UnitConcentrationMass>?
    private let measuredPressureOverride: Measurement<UnitPressure>?

    public var density: Measurement<UnitConcentrationMass>? {
        if let density = _density {
            return density
        }

        guard let altitude = pressureAltitude else { return nil }
        let pressure = ISA.pressure(at: altitude, deltaISA: .init(kelvin: 0))
        let temp: Measurement<UnitTemperature>
        if let t = temperature {
            temp = t
        } else {
            let delta = deltaISA ?? .init(kelvin: 0)
            temp = ISA.temperature(at: altitude, deltaISA: delta)
        }
        let rho = ISA.densityFromPressureAndTemperature(pressure: pressure, temperature: temp)

        return rho
    }

    public var speedOfSound: Measurement<UnitSpeed>? {
        guard let altitude = pressureAltitude else { return nil }
        let temp: Measurement<UnitTemperature>
        if let t = temperature {
            temp = t
        } else {
            let delta = deltaISA ?? .init(kelvin: 0)
            temp = ISA.temperature(at: altitude, deltaISA: delta)
        }
        let speed = ISA.speedOfSoundFromTemperature(temperature: temp)
        return speed
    }

    public var relativePressure: Double? {
        if let p = measuredPressureOverride {
            return p.converted(to: .pascals).value / ISA.seaLevelPressure.pascals
        }
        guard let altitude = pressureAltitude else { return nil }
        let pressure = ISA.pressure(at: altitude, deltaISA: .init(kelvin: 0))
        return pressure.pascals / ISA.seaLevelPressure.pascals
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
