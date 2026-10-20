import Foundation

internal enum BarometricEquations {
    // MARK: - Standard Barometric Conversions (ISA)

    /// Altitude (above the 0-reference of `temperature`/`referencePressure`) at which the
    /// lapse-rate layer ends and the ISA model switches to an isothermal layer.
    /// Matches the troposphere/lower-stratosphere boundary used by `ISA`.
    private static let lapseLayerCeilingMeters: Double = 11_000

    /// Convert pressure to altitude using the two-layer barometric model: a lapse-rate
    /// layer from the reference up to `lapseLayerCeilingMeters`, then an isothermal layer
    /// above it (at the temperature the lapse-rate layer reaches at that ceiling).
    /// Below the ceiling: h = (T₀/L) * (1 - (P/P₀)^(R*L/g))
    /// Above it: h = Ht + (R*Tt/g) * ln(Pt/P), where Tt, Pt are the temperature/pressure at Ht.
    package static func altitudeFromPressure(
        pressure: Measurement<UnitPressure>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.troposphereLapseRate
    ) -> Measurement<UnitLength> {
        let g = ISA.standardGravity.metersPerSecondSquared
        let R = ISA.dryAirGasConstant
        let T0 = temperature.kelvin
        let P0 = referencePressure.pascals
        let P = pressure.pascals

        let exponent = (R * lapseRate) / g
        func lapseLayerAltitude(forPressure p: Double) -> Double {
            T0 / lapseRate * (1 - pow(p / P0, exponent))
        }

        let Ht = lapseLayerCeilingMeters
        let Tt = T0 - lapseRate * Ht
        let Pt = P0 * pow((T0 - lapseRate * Ht) / T0, g / (lapseRate * R))

        guard P < Pt else {
            return .init(meters: lapseLayerAltitude(forPressure: P))
        }

        let altitude = Ht - (R * Tt / g) * log(P / Pt)
        return .init(meters: altitude)
    }

    /// Convert altitude to pressure using the two-layer barometric model: a lapse-rate
    /// layer from the reference up to `lapseLayerCeilingMeters`, then an isothermal layer
    /// above it (at the temperature the lapse-rate layer reaches at that ceiling).
    /// Below the ceiling: P = P₀ * ((T₀ - L*h)/T₀)^(g/(L*R))
    /// Above it: P = Pt * exp(-g*(h - Ht)/(R*Tt)), where Tt, Pt are the temperature/pressure at Ht.
    package static func pressureFromAltitude(
        altitude: Measurement<UnitLength>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.troposphereLapseRate
    ) -> Measurement<UnitPressure> {
        let g = ISA.standardGravity.metersPerSecondSquared
        let R = ISA.dryAirGasConstant
        let T0 = temperature.kelvin
        let P0 = referencePressure.pascals
        let h = altitude.meters

        let exponent = g / (lapseRate * R)
        func lapseLayerPressure(at height: Double) -> Double {
            P0 * pow((T0 - lapseRate * height) / T0, exponent)
        }

        let Ht = lapseLayerCeilingMeters
        guard h > Ht else {
            return .init(pascals: lapseLayerPressure(at: h))
        }

        let Tt = T0 - lapseRate * Ht
        let Pt = lapseLayerPressure(at: Ht)
        let pressureAtAltitude = Pt * exp(-g * (h - Ht) / (R * Tt))
        return .init(pascals: pressureAtAltitude)
    }

    // MARK: - True Altitude Conversions (Non-Standard Atmosphere)

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
