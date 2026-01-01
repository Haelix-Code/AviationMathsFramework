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

    public static func pressureFromQNHAndAMSL(
        qnh: Measurement<UnitPressure>,
        amsl: Measurement<UnitLength>
    ) -> Measurement<UnitPressure> {
        let h = amsl.converted(to: .meters).value
        let T0 = ISA.seaLevelTemperature.kelvin
        let L  = ISA.troposphereLapseRate
        let g  = ISA.standardGravity
        let R  = ISA.dryAirGasConstant

        let tempRatio = max(1e-9, (T0 - L * h) / T0)
        let exponent = g.metersPerSecondSquared / (L * R)
        let p = qnh.converted(to: .pascals).value * pow(tempRatio, exponent)
        return .init(value: p, unit: .pascals)
    }

}
