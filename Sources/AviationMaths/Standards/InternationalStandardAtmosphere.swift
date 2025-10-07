//import Foundation
//
//public class InternationalStandardAtmosphere {
//    public static let seaLevelPressure: Measurement<UnitPressure> = .init(value: 1.01325 * pow(10, 5), unit: .newtonsPerMetersSquared)
//    public static let seaLevelTemperature: Measurement<UnitTemperature> = .init(value: 288.15, unit: .kelvin)
//    public static let tropopauseBaseTemperature: Measurement<UnitTemperature> = .init(value: 216.65, unit: .kelvin)
//    public static let stratosphereBaseTemperature: Measurement<UnitTemperature> = .init(value: 216.65, unit: .kelvin)
//    public static let seaLevelDensity: Measurement<UnitConcentrationMass> = .init(value: 1.225, unit: .gramsPerLiter)
//    public static let seaLevelSpeedOfSound: Measurement<UnitSpeed> = .init(value: 340.294, unit: .metersPerSecond)
//    public static let lapseRateTroposphere: Double = -0.0065 // K/m
//    public static let lapseRateTropopause: Double = 0 // K/m
//    public static let lapseRateStratosphere: Double = 0.001 // K/m
//    public static let standardGravity: Measurement<UnitAcceleration> = .init(value: 9.81, unit: .metersPerSecondSquared)
//    public static let dryAirGasConstant: Double = 287.058 // R
//    public static let barometricExponent: Double = standardGravity.metersPerSecondSquared / (lapseRateTroposphere * dryAirGasConstant)
//    
//    public static let troposphereBaseAltitude: Measurement<UnitLength> = .init(value: 0, unit: .meters)
//    public static let tropopauseBaseAltitude: Measurement<UnitLength> = .init(value: 11000, unit: .meters)
//    public static let stratosphereBaseAltitude: Measurement<UnitLength> = .init(value: 20000, unit: .meters)
//}
//
//extension InternationalStandardAtmosphere {
//    public static var g0: Measurement<UnitAcceleration>  { standardGravity }
//    public static var T0:Measurement<UnitTemperature>  { seaLevelTemperature }
//    public static var L: Double  { lapseRateTroposphere }
//    public static var P0: Measurement<UnitPressure>  { seaLevelPressure }
//    public static var ρ0: Measurement<UnitConcentrationMass>  { seaLevelDensity }
//    public static var a0: Measurement<UnitSpeed>  { seaLevelSpeedOfSound }
//    public static var R: Double  { dryAirGasConstant }
//    public static var n: Double  { barometricExponent }
//}
//
//public typealias ISAConstants = InternationalStandardAtmosphere
//
//struct AthmosphericConditions {
//    let pressureAltitude: Measurement<UnitLength>
//    let temperature: Measurement<UnitTemperature>
//    let pressure: Measurement<UnitPressure>
//    let density: Measurement<UnitConcentrationMass>
//    let speedOfSound: Measurement<UnitSpeed>
//    
//    let relativeTemperature: Double
//    let relativePressure: Double
//    let relativeDensity: Double
//    
//    let densityAltitude: Measurement<UnitLength>
//}
//
//
//
//
//
   
//}
