import Foundation

extension ISA {
    /// Calculate desnity from pressure and temperature using ideal gas law
    /// \(\rho \) = P / ( R x T)
    public static func densityFromPressureAndTemperature(
        pressure: Measurement<UnitPressure>,
        temperature: Measurement<UnitTemperature>
    ) -> Measurement<UnitConcentrationMass> {
        let rho = pressure.pascals / (ISA.dryAirGasConstant * temperature.kelvin)
        return .init(value: rho, unit: .gramsPerLiter)
    }

    // a = ((\sqrt \) \gamma x R  x T)
    public static func speedOfSoundFromTemperature(
        temperature: Measurement<UnitTemperature>
    ) -> Measurement<UnitSpeed> {
        let speedMS = sqrt(ISA.ratioSpecificHeats * ISA.dryAirGasConstant * temperature.kelvin)
        return .init(mps: speedMS)
    }

    /// Static pressure at `amsl` under the same QNH model `Altitude` uses for `.amsl`, so
    /// the two agree at every height, including above the tropopause.
    public static func pressureFromQNHAndAMSL(
        qnh: Measurement<UnitPressure>,
        amsl: Measurement<UnitLength>
    ) -> Measurement<UnitPressure> {
        BarometricEquations.pressureFromAltitude(altitude: amsl, referencePressure: qnh)
    }

}
