import Foundation

enum BarometricEquations {
    /// Convert pressure to altitude using barometric formula
    static func altitudeFromPressure(
        pressure: Measurement<UnitPressure>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.lapseRate(at: .init(meters: 0))
    ) -> Measurement<UnitLength> {
        
        let pressureRatio = pressure.pascals / referencePressure.pascals
        print(pressureRatio)
        let exponent = (lapseRate.magnitude * ISA.dryAirGasConstant * log(pressureRatio)) / ISA.standardGravity.metersPerSecondSquared
        
        let altitude = ISA.seaLevelTemperature.kelvin / lapseRate.magnitude * (1 - exp(exponent))
        
        return .init(meters: altitude)
    }
    
    /// Convert altitude to pressure using barometric formula
    static func pressureFromAltitude(
        altitude: Measurement<UnitLength>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.lapseRate(at: .init(meters: 0))
    ) -> Measurement<UnitPressure> {
        let exponent = ISA.standardGravity.metersPerSecondSquared / (lapseRate.magnitude * ISA.dryAirGasConstant)
        let temperatureRatio = (temperature.kelvin - lapseRate.magnitude * altitude.meters) / temperature.kelvin
        let pressureAtAltitude =  referencePressure.pascals * pow(temperatureRatio, exponent)
        return .init(pascals: pressureAtAltitude)
    }
}
