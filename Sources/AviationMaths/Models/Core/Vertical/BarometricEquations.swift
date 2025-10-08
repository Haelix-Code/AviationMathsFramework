import Foundation

enum BarometricEquations {
    /// Convert pressure to altitude using barometric formula
    /// Formula: h = (T₀/L) × [1 - (P/P_ref)^(R·L/g₀)]
    static func altitudeFromPressure(
        pressure: Double,
        referencePressure: Double,
        temperature: Double = ISA.seaLevelTemperature.kelvin,
        lapseRate: Double = ISA.lapseRate(at: .init(meters: 0))
    ) -> Double {
        let pressureRatio = pressure / referencePressure
        let exponent = (lapseRate * ISA.dryAirGasConstant * log(pressureRatio)) / ISA.standardGravity.metersPerSecondSquared
        
        return (temperature / lapseRate) * (1 - exp(exponent))
    }
    
    /// Convert altitude to pressure using barometric formula
    /// Formula: P = P_ref × [1 - (L·h/T₀)]^(g₀/(R·L))
    static func pressureFromAltitude(
        altitude: Measurement<UnitLength>,
        referencePressure: Measurement<UnitPressure>,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.lapseRate(at: .init(meters: 0))
    ) -> Double {
        let exponent = ISA.standardGravity.metersPerSecondSquared / (lapseRate.magnitude * ISA.dryAirGasConstant)
        let temperatureRatio = (temperature.kelvin - lapseRate.magnitude * altitude.meters) / temperature.kelvin
        return referencePressure.pascals * pow(temperatureRatio, exponent)
    }
}
