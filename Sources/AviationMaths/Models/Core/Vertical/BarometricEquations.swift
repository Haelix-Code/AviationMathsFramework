import Foundation

enum BarometricEquations {
    // MARK: - Standard Barometric Conversions (ISA)
    
    /// Convert pressure to altitude using barometric formula
    /// Formula: h = (T₀/L) * (1 - (P/P₀)^(R*L/g))
    /// where temperature decreases with altitude: T = T₀ - L*h
    static func altitudeFromPressure(
        pressure: Measurement<UnitPressure>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.troposphereLapseRate
    ) -> Measurement<UnitLength> {
        let pressureRatio = pressure.pascals / referencePressure.pascals
        let exponent = (ISA.dryAirGasConstant * lapseRate) / ISA.standardGravity.metersPerSecondSquared
        let altitude = temperature.kelvin / lapseRate * (1 - pow(pressureRatio, exponent))
        return .init(meters: altitude)
    }
    
    /// Convert altitude to pressure using barometric formula
    /// Formula: P = P₀ * ((T₀ - L*h)/T₀)^(g/(L*R))
    /// where temperature decreases with altitude: T = T₀ - L*h
    static func pressureFromAltitude(
        altitude: Measurement<UnitLength>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.troposphereLapseRate
    ) -> Measurement<UnitPressure> {
        let exponent = ISA.standardGravity.metersPerSecondSquared / (lapseRate * ISA.dryAirGasConstant)
        let temperatureRatio = (temperature.kelvin - lapseRate * altitude.meters) / temperature.kelvin
        let pressureAtAltitude = referencePressure.pascals * pow(temperatureRatio, exponent)
        return .init(pascals: pressureAtAltitude)
    }
    
    // MARK: - True Altitude Conversions (Non-Standard Atmosphere)
    
    /// Convert true altitude to pressure using actual temperature profile
    /// Based on: maths.service.ts:: convertVerticalPressurePaTempCToAltitudePA
    static func pressureFromTrueAltitude(
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

        let base = 1.0 - (L * h / T0)
        let exponent = g / (R * L)

        let pressure = referencePressure.pascals * pow(base, exponent)
        return .init(pascals: pressure)
    }
    
    /// Convert pressure to true altitude using actual temperature profile
    /// Based on: maths.service.ts:: convertVerticalPressurePaTempCToAltitudePA
    static func trueAltitudeFromPressure(
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

        let pressureRatio = p / p0
        let exponent = R * L / g

        let altitude = (T0 / L) * (1.0 - pow(pressureRatio, exponent))
        return .init(meters: altitude)
    }
}
