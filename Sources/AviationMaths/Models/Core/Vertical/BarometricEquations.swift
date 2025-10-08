import Foundation

enum BarometricEquations {
    /// Convert pressure to altitude using barometric formula
    /// Formula: h = (T₀/L) × [1 - (P/P_ref)^(R·L/g₀)]
    static func altitudeFromPressure(
        pressure: Double,
        referencePressure: Double,
        temperature: Double = ISA.seaLevelTemperature.kelvin,
        lapseRate: Double = ISA.lapseRate(at: .init(value: 0, unit: .meters))
    ) -> Double {
        let pressureRatio = pressure / referencePressure
        let exponent = (lapseRate * ISA.dryAirGasConstant * log(pressureRatio)) / ISA.standardGravity.metersPerSecondSquared
        
        return (temperature / lapseRate) * (1 - exp(exponent))
    }
    
    /// Convert altitude to pressure using barometric formula
    /// Formula: P = P_ref × [1 - (L·h/T₀)]^(g₀/(R·L))
    static func pressureFromAltitude(
        altitude: Double,
        referencePressure: Double,
        temperature: Double = ISA.seaLevelTemperature.kelvin,
        lapseRate: Double = ISA.lapseRate(at: .init(value: 0, unit: .meters))
    ) -> Double {
        let exponent = ISA.standardGravity.metersPerSecondSquared / (lapseRate * ISA.dryAirGasConstant)
        let temperatureRatio = 1 - (lapseRate * altitude / temperature)
        
        return referencePressure * pow(temperatureRatio, exponent)
    }
}
