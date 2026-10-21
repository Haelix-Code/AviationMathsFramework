import Foundation

public extension SpeedContext {
    /// Initialize with pressure altitude and actual measured temperature
    /// Automatically computes ΔISA and density.
    init(
        pressureAltitude: Measurement<UnitLength>,
        measuredTemperature: Measurement<UnitTemperature>
    ) {
        let isaTemp = ISA.temperature(at: pressureAltitude)
        let delta = Measurement<UnitTemperature>(kelvin: measuredTemperature.kelvin - isaTemp.kelvin)
        let pressure = ISA.pressure(at: pressureAltitude)
        let density = ISA.densityFromPressureAndTemperature(
            pressure: pressure,
            temperature: measuredTemperature
        )
        self.init(
            pressureAltitude: pressureAltitude,
            temperature: measuredTemperature,
            deltaISA: delta,
            density: density
        )
    }

    init(
        measuredPressure: Measurement<UnitPressure>,
        measuredTemperature: Measurement<UnitTemperature>
    ) {
        let rho = ISA.densityFromPressureAndTemperature(
            pressure: measuredPressure,
            temperature: measuredTemperature
        )
        // Pressure altitude is the altitude in the *standard* atmosphere that
        // yields this pressure, independent of the measured temperature. Without
        // it, speedOfSound/Mach are unreachable even though temperature is known.
        let derivedPressureAltitude = BarometricEquations.altitudeFromPressure(
            pressure: measuredPressure,
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
        self.init(
            pressureAltitude: derivedPressureAltitude,
            temperature: measuredTemperature,
            deltaISA: nil,
            density: rho,
            measuredPressure: measuredPressure
        )
    }

    static func fromQNHAndAMSL(
        qnh: Measurement<UnitPressure>,
        amsl: Measurement<UnitLength>,
        measuredTemperature: Measurement<UnitTemperature>
    ) -> SpeedContext {
        let P = ISA.pressureFromQNHAndAMSL(qnh: qnh, amsl: amsl)
        return SpeedContext(measuredPressure: P, measuredTemperature: measuredTemperature)
    }
}
