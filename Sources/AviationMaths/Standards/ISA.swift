import Foundation

/// International Standard Atmosphere (ISA) model for aviation calculations.
///
/// Implements the ICAO Standard Atmosphere (ISO 2533:1975) for altitudes from 0 to 20,000 meters,
/// covering the troposphere (0-11km) and lower stratosphere (11-20km).
/// All units used in calculations are SI.
public struct ISA {
    
    // MARK: - Physical Constants
    
    public static let standardGravity: Measurement<UnitAcceleration> =
        .init(value: 9.80665, unit: .metersPerSecondSquared)
    public static let dryAirGasConstant: Double = 287.058
    public static let ratioSpecificHeats: Double = 1.4
    
    public static let seaLevelPressure: Measurement<UnitPressure> =
        .init(value: 1.01325e5, unit: .newtonsPerMetersSquared)
    public static let seaLevelTemperature: Measurement<UnitTemperature> =
        .init(value: 288.15, unit: .kelvin)
    public static let seaLevelDensity: Measurement<UnitConcentrationMass> =
        .init(value: 1.225, unit: .gramsPerLiter)
    public static let seaLevelSpeedOfSound: Measurement<UnitSpeed> =
        .init(value: 340.294, unit: .metersPerSecond)
    
    // MARK: - Atmospheric Layer Definitions
    
    private static let troposphereBase: Measurement<UnitLength> = .init(value: 0, unit: .meters)
    private static let lowerStratosphereBase: Measurement<UnitLength> = .init(value: 11_000, unit: .meters)
    private static let modelUpperLimit: Measurement<UnitLength> = .init(value: 20_000, unit: .meters)
    private static let troposphereLapseRate: Double = -0.0065
    private static let lowerStratosphereLapseRate: Double = 0.0
    private static let tropopauseTemperature: Double =
    seaLevelTemperature.value + troposphereLapseRate * (lowerStratosphereBase.meters - troposphereBase.meters)
    
    // MARK: - Instance Properties
    
    public let altitude: Measurement<UnitLength>
    public let deltaISA: Measurement<UnitTemperature>
    
    // MARK: - Initializers

    public init(altitude: Measurement<UnitLength>,
                deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)) {
        let altitudeMeters = altitude.meters
        
        if altitudeMeters < -5000 {
//            print("⚠️ ISA Warning: Altitude \(altitudeMeters)m is below valid range. Clamping to -5,000m.")
            self.altitude = .init(meters: -5000)
        } else if altitudeMeters > Self.modelUpperLimit.meters {
//            print("⚠️ ISA Warning: Altitude \(altitudeMeters)m exceeds model validity (20,000m). Results may be inaccurate.")
            self.altitude = altitude
        } else {
            self.altitude = altitude
        }
        
        self.deltaISA = deltaISA
    }
    
    public init(altitudeMeters: Double, deltaISA: Double = 0) {
        self.init(
            altitude: .init(meters: altitudeMeters),
            deltaISA: .init(kelvin: deltaISA)
        )
    }
    
    public init(altitudeFeet: Double, deltaISA: Double = 0) {
        self.init(
            altitude: .init(feet: altitudeFeet),
            deltaISA: .init(kelvin: deltaISA)
        )
    }
    
    public static func seaLevel(deltaISA: Double = 0) -> ISA {
        return ISA(altitudeMeters: 0, deltaISA: deltaISA)
    }
    
    // MARK: - Computed Properties
    
    public var temperature: Measurement<UnitTemperature> {
        let altitudeMeters = altitude.meters
        let deltaK = deltaISA.kelvin
        
        let standardTemp: Double
        if altitudeMeters < Self.lowerStratosphereBase.meters {
            // Troposphere: T = T₀ + L × h
            standardTemp = Self.seaLevelTemperature.value +
                          Self.troposphereLapseRate * altitudeMeters
        } else {
            // Lower stratosphere: isothermal at tropopause temperature
            standardTemp = Self.tropopauseTemperature
        }
        
        return .init(kelvin: standardTemp + deltaK)
    }

    public var pressure: Measurement<UnitPressure> {
        let altitudeMeters = altitude.meters
        let deltaK = deltaISA.kelvin
        let g = Self.standardGravity.value
        let R = Self.dryAirGasConstant
        
        var pressurePa = Self.seaLevelPressure.value
        var currentAlt = Self.troposphereBase.meters
        var currentTemp = Self.seaLevelTemperature.value + deltaK
        
        // Layer 1: Troposphere (0 - 11km)
        if altitudeMeters > Self.troposphereBase.meters {
            let topAlt = min(altitudeMeters, Self.lowerStratosphereBase.meters)
            let deltaH = topAlt - currentAlt
            let L = Self.troposphereLapseRate
            let tempAtTop = currentTemp + L * deltaH
            
            let exponent = -g / (L * R)
            pressurePa *= pow(tempAtTop / currentTemp, exponent)
            
            currentAlt = topAlt
            currentTemp = tempAtTop
        }
        
        // Layer 2: Lower Stratosphere (11 - 20km)
        if altitudeMeters > Self.lowerStratosphereBase.meters {
            let deltaH = altitudeMeters - currentAlt
            let tempIsothermal = Self.tropopauseTemperature + deltaK
            
            let exponent = -g * deltaH / (R * tempIsothermal)
            pressurePa *= exp(exponent)
        }
        
        return .init(pascals: pressurePa)
    }
    
    public var density: Measurement<UnitConcentrationMass> {
        let pressurePa = pressure.pascals
        let tempK = temperature.kelvin
        let rho = pressurePa / (Self.dryAirGasConstant * tempK)
        
        return .init(value: rho, unit: .gramsPerLiter)
    }
    
    public var speedOfSound: Measurement<UnitSpeed> {
        let tempK = temperature.kelvin
        let speedMS = sqrt(Self.ratioSpecificHeats * Self.dryAirGasConstant * tempK)
        
        return .init(mps: speedMS)
    }
    
    public var lapseRate: Double {
        let altitudeMeters = altitude.meters
        if altitudeMeters > Self.lowerStratosphereBase.meters {
            return Self.lowerStratosphereLapseRate
        } else {
            return Self.troposphereLapseRate
        }
    }
    
}

// MARK: - Static Calculation Methods

extension ISA {
    public static func temperature(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitTemperature> {
        return ISA(altitude: altitude, deltaISA: deltaISA).temperature
    }

    public static func pressure(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitPressure> {
        return ISA(altitude: altitude, deltaISA: deltaISA).pressure
    }
    
    public static func density(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitConcentrationMass> {
        return ISA(altitude: altitude, deltaISA: deltaISA).density
    }
    
    public static func speedOfSound(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitSpeed> {
        return ISA(altitude: altitude, deltaISA: deltaISA).speedOfSound
    }
    
    public static func lapseRate(
        at altitude: Measurement<UnitLength>) -> Double {
            return ISA(altitude: altitude).lapseRate
        }
}
