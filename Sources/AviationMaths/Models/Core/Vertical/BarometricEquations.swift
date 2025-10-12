import Foundation

enum BarometricEquations {
    /// Convert pressure to altitude using barometric formula
    static func altitudeFromPressure(
        pressure: Measurement<UnitPressure>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.lapseRate(at: .surface)
    ) -> Measurement<UnitLength> {
        let pressureRatio = pressure.pascals / referencePressure.pascals
        let exponent = (ISA.dryAirGasConstant * lapseRate.magnitude) / ISA.standardGravity.metersPerSecondSquared
        let altitude = temperature.kelvin / lapseRate.magnitude * (1 - pow(pressureRatio, exponent))
        return .init(meters: altitude)
    }
    
    /// Convert altitude to pressure using barometric formula
    static func pressureFromAltitude(
        altitude: Measurement<UnitLength>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        temperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.lapseRate(at: .surface)
    ) -> Measurement<UnitPressure> {
        let exponent = ISA.standardGravity.metersPerSecondSquared / (lapseRate.magnitude * ISA.dryAirGasConstant)
        let temperatureRatio = (temperature.kelvin - lapseRate.magnitude * altitude.meters) / temperature.kelvin
        let pressureAtAltitude =  referencePressure.pascals * pow(temperatureRatio, exponent)
        return .init(pascals: pressureAtAltitude)
    }
    
    // ETPS/GS/B1&D1V2.0 Equation (4)
    static func geopotentialAltitude(
        pressureAtAltitude: Measurement<UnitPressure>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        referenceTemperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.lapseRate(at: .surface)
    ) -> Measurement<UnitLength>{
        let exponent = -(lapseRate * ISA.dryAirGasConstant) / ISA.standardGravity.metersPerSecondSquared
        let pressureRatio = pressureAtAltitude.pascals / referencePressure.pascals
        let geopotentialAltitude = (referenceTemperature.kelvin / lapseRate) * (pow(pressureRatio,exponent) - 1)
        
        return .init(meters: geopotentialAltitude)
    }
    
    // Inverse
    static func pressureFromGeopotentialAltitude(
        geopotentialAltitude: Measurement<UnitLength>,
        referencePressure: Measurement<UnitPressure> = ISA.seaLevelPressure,
        referenceTemperature: Measurement<UnitTemperature> = ISA.seaLevelTemperature,
        lapseRate: Double = ISA.lapseRate(at: .surface)
    ) -> Measurement<UnitPressure> {
        let ratio = 1 + (geopotentialAltitude.meters * lapseRate / referenceTemperature.kelvin)
        let exponent = -ISA.standardGravity.metersPerSecondSquared / (lapseRate * ISA.dryAirGasConstant)
        let pressure = referencePressure.pascals * pow(ratio,exponent)
        return .init(pascals: pressure)
    }
}
