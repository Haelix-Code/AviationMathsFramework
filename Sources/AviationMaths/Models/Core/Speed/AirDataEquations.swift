import Foundation

/// Air data equations for speed conversions based on ICAO Standard Atmosphere
///
/// These equations handle compressibility effects and convert between different
/// airspeed references using standard atmospheric relationships.
///
/// References:
/// - ICAO Standard Atmosphere (Doc 7488)
/// - US Standard Atmosphere 1976
internal enum AirDataEquations {

    private static let gamma: Double = ISA.ratioSpecificHeats  // 1.4

    private static let seaLevelSpeedOfSound: Double = ISA.seaLevelSpeedOfSound.mps  // 340.294 m/s

    private static let seaLevelDensity: Double = ISA.seaLevelDensity.value  // 1.225 kg/m³

    package static func impactPressureCoefficient(fromMach mach: Double) -> Double {
        let gamma = ISA.ratioSpecificHeats
        if mach < 1.0 {
            return pow(1.0 + (gamma - 1.0) / 2.0 * pow(mach, 2),
                          gamma / (gamma - 1.0)) - 1.0
        }
        return rayleighImpactPressureCoefficient(mach: mach, gamma: gamma)
    }

    /// Rayleigh supersonic pitot relation (air crosses a shock ahead of the probe).
    private static func rayleighImpactPressureCoefficient(mach: Double, gamma: Double) -> Double {
        let m2 = mach * mach
        let shockTerm = pow(
            ((gamma + 1.0) * (gamma + 1.0) * m2) / (4.0 * gamma * m2 - 2.0 * (gamma - 1.0)),
            gamma / (gamma - 1.0)
        )
        let staticTerm = (1.0 - gamma + 2.0 * gamma * m2) / (gamma + 1.0)
        return shockTerm * staticTerm - 1.0
    }

    static func machNumber(fromImpactPressureCoefficient qc: Double) -> Double {
        let gamma = ISA.ratioSpecificHeats
        let subsonicMax = rayleighImpactPressureCoefficient(mach: 1.0, gamma: gamma)
        if qc <= subsonicMax {
            return sqrt(5.0 * (pow(qc + 1.0, 2.0/7.0) - 1.0))
        }
        return supersonicMachNumber(fromImpactPressureCoefficient: qc, gamma: gamma)
    }

    /// Rayleigh's forward relation has no closed-form inverse; qc/p is monotonic
    /// in M for M ≥ 1, so bisection finds the Mach number it corresponds to.
    private static func supersonicMachNumber(fromImpactPressureCoefficient qc: Double, gamma: Double) -> Double {
        var low = 1.0
        var high = 10.0
        while rayleighImpactPressureCoefficient(mach: high, gamma: gamma) < qc {
            high *= 2.0
        }
        for _ in 0..<100 {
            let mid = (low + high) / 2.0
            if rayleighImpactPressureCoefficient(mach: mid, gamma: gamma) < qc {
                low = mid
            } else {
                high = mid
            }
        }
        return (low + high) / 2.0
    }

    /// Mach from CAS needs only the pressure ratio: CAS fixes qc, and qc/p fixes Mach.
    static func machNumber(
        fromCalibratedAirspeed cas: Measurement<UnitSpeed>,
        relativePressure delta: Double
    ) -> Double {
        let machAtSeaLevel = cas.mps / seaLevelSpeedOfSound
        let qcAtSeaLevel = impactPressureCoefficient(fromMach: machAtSeaLevel)
        let qcAtAltitude = qcAtSeaLevel / delta
        return machNumber(fromImpactPressureCoefficient: qcAtAltitude)
    }

    static func equivalentAirspeed(
        fromCalibratedAirspeed cas: Measurement<UnitSpeed>,
        relativePressure delta: Double
    ) -> Measurement<UnitSpeed> {
        let machAtAltitude = machNumber(fromCalibratedAirspeed: cas, relativePressure: delta)
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
        let densityRatio = seaLevelDensity / density.converted(to: .gramsPerLiter).value
        let tas = eas.mps * sqrt(densityRatio)
        return .init(mps: tas)
    }

    static func equivalentAirspeed(
        fromTrueAirspeed tas: Measurement<UnitSpeed>,
        density: Measurement<UnitConcentrationMass>
    ) -> Measurement<UnitSpeed> {
        let densityRatio = density.converted(to: .gramsPerLiter).value / seaLevelDensity
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
