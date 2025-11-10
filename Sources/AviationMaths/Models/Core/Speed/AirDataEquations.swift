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
    
    // MARK: - Physical Constants
    
    /// Ratio of specific heats for air (dimensionless)
    private static let gamma: Double = ISA.ratioSpecificHeats  // 1.4
    
    /// Sea level speed of sound (m/s)
    private static let seaLevelSpeedOfSound: Double = ISA.seaLevelSpeedOfSound.mps  // 340.294 m/s
    
    /// Sea level density (kg/m³)
    private static let seaLevelDensity: Double = ISA.seaLevelDensity.value  // 1.225 kg/m³
    
    // MARK: - Impact Pressure Coefficient (qc)
    
    /// Calculate impact pressure coefficient from Mach number
    ///
    /// Formula: qc = ((1 + 0.2·M²)^3.5 - 1)
    /// This represents (P_total - P_static) / P_static
    ///
    /// - Parameter mach: Mach number (dimensionless)
    /// - Returns: Impact pressure coefficient (dimensionless)
    static func impactPressureCoefficient(fromMach mach: Double) -> Double {
        return pow(1.0 + 0.2 * pow(mach, 2), 3.5) - 1.0
    }
    
    /// Calculate Mach number from impact pressure coefficient
    ///
    /// Formula: M = √(5·((qc + 1)^(2/7) - 1))
    /// Inverse of the impact pressure coefficient formula
    ///
    /// - Parameter qc: Impact pressure coefficient (dimensionless)
    /// - Returns: Mach number (dimensionless)
    static func machNumber(fromImpactPressureCoefficient qc: Double) -> Double {
        return sqrt(5.0 * (pow(qc + 1.0, 2.0/7.0) - 1.0))
    }
    
    // MARK: - CAS ↔ EAS Conversions (Compressibility Corrections)
    
    /// Convert Calibrated Airspeed to Equivalent Airspeed
    ///
    /// CAS is corrected for compressibility effects using the pressure ratio at altitude.
    /// This is the "Scale Altitude Correction" in your Python code.
    ///
    /// Process:
    /// 1. Calculate impact pressure at sea level (from CAS)
    /// 2. Convert to impact pressure at altitude (using δ)
    /// 3. Calculate Mach number at altitude
    /// 4. Calculate EAS from Mach and δ
    ///
    /// - Parameters:
    ///   - cas: Calibrated airspeed
    ///   - relativePressure: Pressure ratio δ = P/P₀ (dimensionless)
    /// - Returns: Equivalent airspeed
    static func equivalentAirspeed(
        fromCalibratedAirspeed cas: Measurement<UnitSpeed>,
        relativePressure delta: Double
    ) -> Measurement<UnitSpeed> {
        // Step 1: Calculate Mach at sea level from CAS
        let machAtSeaLevel = cas.mps / seaLevelSpeedOfSound
        
        // Step 2: Calculate impact pressure coefficient at sea level
        let qcAtSeaLevel = impactPressureCoefficient(fromMach: machAtSeaLevel)
        
        // Step 3: Convert to impact pressure coefficient at altitude
        // qc_altitude = qc_sea_level / δ
        let qcAtAltitude = qcAtSeaLevel / delta
        
        // Step 4: Calculate Mach number at altitude
        let machAtAltitude = machNumber(fromImpactPressureCoefficient: qcAtAltitude)
        
        // Step 5: Calculate EAS from Mach and pressure ratio
        // Formula: V_e = M·a₀·√δ  (from your Python V_e_from_M_relative_pressure)
        let eas = machAtAltitude * seaLevelSpeedOfSound * sqrt(delta)
        
        return .init(mps: eas)
    }
    
    /// Convert Equivalent Airspeed to Calibrated Airspeed
    ///
    /// Reverse of the CAS → EAS conversion.
    ///
    /// - Parameters:
    ///   - eas: Equivalent airspeed
    ///   - relativePressure: Pressure ratio δ = P/P₀ (dimensionless)
    /// - Returns: Calibrated airspeed
    static func calibratedAirspeed(
        fromEquivalentAirspeed eas: Measurement<UnitSpeed>,
        relativePressure delta: Double
    ) -> Measurement<UnitSpeed> {
        // Step 1: Calculate Mach at altitude from EAS
        // From V_e = M·a₀·√δ, we get: M = V_e / (a₀·√δ)
        let machAtAltitude = eas.mps / (seaLevelSpeedOfSound * sqrt(delta))
        
        // Step 2: Calculate impact pressure coefficient at altitude
        let qcAtAltitude = impactPressureCoefficient(fromMach: machAtAltitude)
        
        // Step 3: Convert to impact pressure coefficient at sea level
        let qcAtSeaLevel = qcAtAltitude * delta
        
        // Step 4: Calculate Mach at sea level
        let machAtSeaLevel = machNumber(fromImpactPressureCoefficient: qcAtSeaLevel)
        
        // Step 5: Calculate CAS
        let cas = machAtSeaLevel * seaLevelSpeedOfSound
        
        return .init(mps: cas)
    }
    
    // MARK: - EAS ↔ TAS Conversions (Density Corrections)
    
    /// Convert Equivalent Airspeed to True Airspeed
    ///
    /// Formula: TAS = EAS / √(ρ/ρ₀)
    /// or equivalently: TAS = EAS · √(ρ₀/ρ)
    ///
    /// - Parameters:
    ///   - eas: Equivalent airspeed
    ///   - density: Air density at altitude
    /// - Returns: True airspeed
    static func trueAirspeed(
        fromEquivalentAirspeed eas: Measurement<UnitSpeed>,
        density: Measurement<UnitConcentrationMass>
    ) -> Measurement<UnitSpeed> {
        let densityRatio = seaLevelDensity / density.value
        let tas = eas.mps * sqrt(densityRatio)
        return .init(mps: tas)
    }
    
    /// Convert True Airspeed to Equivalent Airspeed
    ///
    /// Formula: EAS = TAS · √(ρ/ρ₀)
    ///
    /// - Parameters:
    ///   - tas: True airspeed
    ///   - density: Air density at altitude
    /// - Returns: Equivalent airspeed
    static func equivalentAirspeed(
        fromTrueAirspeed tas: Measurement<UnitSpeed>,
        density: Measurement<UnitConcentrationMass>
    ) -> Measurement<UnitSpeed> {
        let densityRatio = density.value / seaLevelDensity
        let eas = tas.mps * sqrt(densityRatio)
        return .init(mps: eas)
    }
    
    // MARK: - Mach Number Conversions
    
    /// Convert True Airspeed to Mach number
    ///
    /// Formula: M = TAS / a
    /// where a is the local speed of sound
    ///
    /// - Parameters:
    ///   - tas: True airspeed
    ///   - speedOfSound: Speed of sound at altitude
    /// - Returns: Mach number (dimensionless)
    static func machNumber(
        fromTrueAirspeed tas: Measurement<UnitSpeed>,
        speedOfSound: Measurement<UnitSpeed>
    ) -> Double {
        return tas.mps / speedOfSound.mps
    }
    
    /// Convert Mach number to True Airspeed
    ///
    /// Formula: TAS = M · a
    ///
    /// - Parameters:
    ///   - mach: Mach number (dimensionless)
    ///   - speedOfSound: Speed of sound at altitude
    /// - Returns: True airspeed
    static func trueAirspeed(
        fromMachNumber mach: Double,
        speedOfSound: Measurement<UnitSpeed>
    ) -> Measurement<UnitSpeed> {
        return .init(mps: mach * speedOfSound.mps)
    }
}
