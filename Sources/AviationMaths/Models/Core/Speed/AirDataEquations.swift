import Foundation

/// Air data equations for speed conversions based on ICAO Standard Atmosphere
///
/// These equations handle compressibility effects and convert between different
/// airspeed references using standard atmospheric relationships.
///
/// References:
/// - ICAO Standard Atmosphere (Doc 7488)
/// - US Standard Atmosphere 1976
enum AirDataEquations {
    

    private static let gamma: Double = ISA.ratioSpecificHeats  // 1.4
    
    private static let seaLevelSpeedOfSound: Double = ISA.seaLevelSpeedOfSound.mps  // 340.294 m/s
    
    private static let seaLevelDensity: Double = ISA.seaLevelDensity.value  // 1.225 kg/m³
    

    static func impactPressureCoefficient(fromMach mach: Double) -> Double {
        let gamma = ISA.ratioSpecificHeats
        return pow(1.0 + (gamma - 1.0) / 2.0 * pow(mach, 2),
                      gamma / (gamma - 1.0)) - 1.0
    }

    static func machNumber(fromImpactPressureCoefficient qc: Double) -> Double {
        return sqrt(5.0 * (pow(qc + 1.0, 2.0/7.0) - 1.0))
    }
    
    static func equivalentAirspeed(
        fromCalibratedAirspeed cas: Measurement<UnitSpeed>,
        relativePressure delta: Double
    ) -> Measurement<UnitSpeed> {
        let machAtSeaLevel = cas.mps / seaLevelSpeedOfSound
        let qcAtSeaLevel = impactPressureCoefficient(fromMach: machAtSeaLevel)
        let qcAtAltitude = qcAtSeaLevel / delta
        let machAtAltitude = machNumber(fromImpactPressureCoefficient: qcAtAltitude)
        let eas = machAtAltitude * seaLevelSpeedOfSound * sqrt(delta)
        
        return .init(mps: eas)
    }
    
    static func calibratedAirspeed(
        fromEquivalentAirspeed eas: Measurement<UnitSpeed>,
        relativePressure delta: Double
    ) -> Measurement<UnitSpeed> {
        let machAtAltitude = eas.mps / (seaLevelSpeedOfSound * sqrt(delta))
        let qcAtAltitude = impactPressureCoefficient(fromMach: machAtAltitude)
        let qcAtSeaLevel = qcAtAltitude * delta
        let machAtSeaLevel = machNumber(fromImpactPressureCoefficient: qcAtSeaLevel)
        let cas = machAtSeaLevel * seaLevelSpeedOfSound
        
        return .init(mps: cas)
    }
    
    static func trueAirspeed(
        fromEquivalentAirspeed eas: Measurement<UnitSpeed>,
        density: Measurement<UnitConcentrationMass>
    ) -> Measurement<UnitSpeed> {
        let densityRatio = seaLevelDensity / density.value
        let tas = eas.mps * sqrt(densityRatio)
        return .init(mps: tas)
    }

    static func equivalentAirspeed(
        fromTrueAirspeed tas: Measurement<UnitSpeed>,
        density: Measurement<UnitConcentrationMass>
    ) -> Measurement<UnitSpeed> {
        let densityRatio = density.value / seaLevelDensity
        let eas = tas.mps * sqrt(densityRatio)
        return .init(mps: eas)
    }
    

    static func machNumber(
        fromTrueAirspeed tas: Measurement<UnitSpeed>,
        speedOfSound: Measurement<UnitSpeed>
    ) -> Double {
        return tas.mps / speedOfSound.mps
    }

    static func trueAirspeed(
        fromMachNumber mach: Double,
        speedOfSound: Measurement<UnitSpeed>
    ) -> Measurement<UnitSpeed> {
        return .init(mps: mach * speedOfSound.mps)
    }
}
