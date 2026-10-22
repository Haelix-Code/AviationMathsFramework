import Foundation

internal enum BarometricEquations {
    // MARK: - Standard Barometric Conversions (ISA)

    /// Convert pressure to altitude through the ICAO layers (see `LayeredAtmosphere`),
    /// starting from `referencePressure` and `temperature` at height 0 with `lapseRate`
    /// in the bottom layer. The defaults are the ISA itself.
    package static func altitudeFromPressure(
        pressure: Measurement<UnitPressure>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.troposphereLapseRate
    ) -> Measurement<UnitLength> {
        let atmosphere = LayeredAtmosphere(
            baseTemperature: temperature.kelvin,
            basePressure: referencePressure.pascals,
            lowestLayerLapseRate: lapseRate
        )
        return .init(meters: atmosphere.altitude(atPressure: pressure.pascals))
    }

    /// Convert altitude to pressure through the ICAO layers (see `LayeredAtmosphere`),
    /// starting from `referencePressure` and `temperature` at height 0 with `lapseRate`
    /// in the bottom layer. The defaults are the ISA itself.
    package static func pressureFromAltitude(
        altitude: Measurement<UnitLength>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.troposphereLapseRate
    ) -> Measurement<UnitPressure> {
        let atmosphere = LayeredAtmosphere(
            baseTemperature: temperature.kelvin,
            basePressure: referencePressure.pascals,
            lowestLayerLapseRate: lapseRate
        )
        return .init(pascals: atmosphere.pressure(at: altitude.meters))
    }

    // MARK: - True Altitude Conversions (Non-Standard Atmosphere)

    /// Height above which the true-altitude temperature profile stops using the context's
    /// lapse rate and follows the ISA layers offset by the ΔISA reached there (ISA + ΔISA).
    private static let tropopauseMeters: Double = 11_000

    /// Convert true altitude to pressure using actual temperature profile
    /// Based on: maths.service.ts:: convertVerticalPressurePaTempCToAltitudePA
    package static func pressureFromTrueAltitude(
        trueAltitude: Measurement<UnitLength>,
        referencePressure: Measurement<UnitPressure>,
        referenceTemperature: Measurement<UnitTemperature>,
        lapseRate: Double
    ) -> Measurement<UnitPressure> {
        let g = ISA.standardGravity.metersPerSecondSquared
        let R = ISA.dryAirGasConstant

        let h = trueAltitude.meters
        let T0 = referenceTemperature.kelvin
        let L = lapseRate

        guard h <= tropopauseMeters else {
            let atmosphere = LayeredAtmosphere(
                baseTemperature: T0, basePressure: referencePressure.pascals, lowestLayerLapseRate: L
            )
            return .init(pascals: atmosphere.pressure(at: h))
        }

        guard abs(L) > 1e-9 else {
            // Isothermal layer: the lapse-rate formula divides by L, so use
            // the exponential barometric formula instead.
            let pressure = referencePressure.pascals * exp(-g * h / (R * T0))
            return .init(pascals: pressure)
        }

        let base = 1.0 - (L * h / T0)
        let exponent = g / (R * L)

        let pressure = referencePressure.pascals * pow(base, exponent)
        return .init(pascals: pressure)
    }

    /// Convert pressure to true altitude using actual temperature profile
    /// Based on: maths.service.ts:: convertVerticalPressurePaTempCToAltitudePA
    package static func trueAltitudeFromPressure(
        pressure: Measurement<UnitPressure>,
        referencePressure: Measurement<UnitPressure>,
        referenceTemperature: Measurement<UnitTemperature>,
        lapseRate: Double
    ) -> Measurement<UnitLength> {
        let g = ISA.standardGravity.metersPerSecondSquared
        let R = ISA.dryAirGasConstant

        let p = pressure.pascals
        let p0 = referencePressure.pascals
        let T0 = referenceTemperature.kelvin
        let L = lapseRate

        let atmosphere = LayeredAtmosphere(baseTemperature: T0, basePressure: p0, lowestLayerLapseRate: L)
        guard p >= atmosphere.pressure(at: tropopauseMeters) else {
            return .init(meters: atmosphere.altitude(atPressure: p))
        }

        guard abs(L) > 1e-9 else {
            // Isothermal layer: (T0/L)*(1-pow(ratio,0)) is Infinity*0 = NaN for
            // every input, so use the inverse of the exponential formula instead.
            let altitude = (R * T0 / g) * log(p0 / p)
            return .init(meters: altitude)
        }

        let pressureRatio = p / p0
        let exponent = R * L / g

        let altitude = (T0 / L) * (1.0 - pow(pressureRatio, exponent))
        return .init(meters: altitude)
    }
}
