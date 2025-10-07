import Foundation

public struct InternationalStandardAthmosphere {
    public static let standardGravity: Measurement<UnitAcceleration> = .init(value: 9.81, unit: .metersPerSecondSquared)
    public static let dryAirGasConstant: Double = 287.058 // R
    public static let ratioSpecificHeats: Double = 1.4 // ratio of specific heats
    
    public static let seaLevelPressure: Measurement<UnitPressure> = .init(value: 1.01325 * pow(10, 5), unit: .newtonsPerMetersSquared) // Pa
    public static let seaLevelTemperature: Measurement<UnitTemperature> = .init(value: 288.15, unit: .kelvin) // K
    public static let seaLevelDensity: Measurement<UnitConcentrationMass> = .init(value: 1.225, unit: .gramsPerLiter) // g/L
    public static let seaLevelSpeedOfSound: Measurement<UnitSpeed> = .init(value: 340.294, unit: .metersPerSecond) // m/s
    
    // Base altitudes (meters)
    public static let troposphereBaseAltitude: Measurement<UnitLength> = .init(value: 0, unit: .meters)
    public static let tropopauseBaseAltitude: Measurement<UnitLength> = .init(value: 11_000, unit: .meters)
    public static let stratosphereBaseAltitude: Measurement<UnitLength> = .init(value: 20_000, unit: .meters)
    
    // Lapse rates (K / m)
    public static let lapseRateTroposphere: Double = -0.0065
    public static let lapseRateTropopause: Double = 0.0
    public static let lapseRateStratosphere: Double = 0.001
    
    private enum Band {
        case troposphere
        case tropopause
        case stratosphere
        
        var baseAltitude: Measurement<UnitLength> {
            switch self {
            case .troposphere: return ISA.troposphereBaseAltitude
            case .tropopause:  return ISA.tropopauseBaseAltitude
            case .stratosphere:return ISA.stratosphereBaseAltitude
            }
        }
        var lapseRate: Double {
            switch self {
            case .troposphere: return ISA.lapseRateTroposphere
            case .tropopause:  return ISA.lapseRateTropopause
            case .stratosphere:return ISA.lapseRateStratosphere
            }
        }
        /// base temperature (K) at this band's base (computed)
        var baseTemperature_K: Double {
            switch self {
            case .troposphere:
                return ISA.seaLevelTemperature.converted(to: .kelvin).value
            case .tropopause:
                // temperature at tropopause = T0 + L_tropo * (h_tropopause - h_troposphere)
                let T0 = ISA.seaLevelTemperature.converted(to: .kelvin).value
                let L = ISA.lapseRateTroposphere
                let h = ISA.tropopauseBaseAltitude.meters - ISA.troposphereBaseAltitude.meters
                return T0 + L * h
            case .stratosphere:
                // base temperature of stratosphere = tropopause base temp in this simple model
                return Band.tropopause.baseTemperature_K
            }
        }
    }
    
    public var altitude: Measurement<UnitLength>? {
        didSet { self.syncBandToAltitude() }
    }
    
    /// Optional delta ISA (applies to temperatures)
    public var deltaISA: Measurement<UnitTemperature>
    
    // private representation of current band
    private var currentBand: Band = .troposphere
    
    // MARK: - Initializers
    public init(altitude: Measurement<UnitLength>? = nil,
                deltaISA: Measurement<UnitTemperature> = .init(value: 0, unit: .kelvin)) {
        self.altitude = altitude
        self.deltaISA = deltaISA
        self.syncBandToAltitude()
    }
    
    // MARK: - Sync helpers
    private mutating func syncBandToAltitude() {
        guard let alt = altitude else {
            currentBand = .troposphere
            return
        }
        let h_m = alt.converted(to: .meters).value
        if h_m < ISA.tropopauseBaseAltitude.meters {
            currentBand = .troposphere
        } else if h_m < ISA.stratosphereBaseAltitude.meters {
            currentBand = .tropopause
        } else {
            currentBand = .stratosphere
        }
    }
    
    
    /// Base altitude of the current band (Measurement)
    public var baseAltitude: Measurement<UnitLength> {
        currentBand.baseAltitude
    }
    /// Base temperature at that base (Measurement)
    public var baseTemperature: Measurement<UnitTemperature> {
        let tK = currentBand.baseTemperature_K + deltaISA.converted(to: .kelvin).value
        return Measurement(value: tK, unit: .kelvin)
    }
    /// Lapse rate (K/m) for the current band
    public var lapseRate: Double {
        currentBand.lapseRate
    }
    // Convenience: expose top-level familiar names mapped to instance values
    public var T0: Measurement<UnitTemperature> { ISA.seaLevelTemperature }
    public var P0: Measurement<UnitPressure> { ISA.seaLevelPressure }
    public var ρ0: Measurement<UnitConcentrationMass> { ISA.seaLevelDensity }
    public var a0: Measurement<UnitSpeed> { ISA.seaLevelSpeedOfSound }
    public var g0: Measurement<UnitAcceleration> { ISA.standardGravity }
    public var R: Double { ISA.dryAirGasConstant }
    public var γ: Double { ISA.ratioSpecificHeats }
   
   // MARK: - Calculation helpers (default to instance altitude if nil)
   
   /// Temperature at `altitude` (if nil, use instance altitude). deltaISA parameter overrides instance deltaISA if passed.
   public func temperature(at altitude: Measurement<UnitLength>? = nil,
                           deltaISA: Measurement<UnitTemperature>? = nil) -> Measurement<UnitTemperature> {
       // choose target altitude: parameter first, then instance altitude, else use 0 (sea level)
       let targetH_m: Double
       if let alt = altitude {
           targetH_m = alt.converted(to: .meters).value
       } else if let instH = self.altitude {
           targetH_m = instH.converted(to: .meters).value
       } else {
           targetH_m = ISA.troposphereBaseAltitude.meters
       }
       let dISA_K = (deltaISA ?? self.deltaISA).converted(to: .kelvin).value
       
       // Determine which band contains target (we evaluate formula using band of target)
       let band: Band = {
           if targetH_m < ISA.tropopauseBaseAltitude.meters { return .troposphere }
           else if targetH_m < ISA.stratosphereBaseAltitude.meters { return .tropopause }
           else { return .stratosphere }
       }()
       
       let Tbase = band.baseTemperature_K
       let L = band.lapseRate
       let hBase = band.baseAltitude
       
       let T_K: Double
       if L == 0 {
           // isothermal for that band
           T_K = Tbase + dISA_K
       } else {
           T_K = (Tbase + L * (targetH_m - hBase.meters)) + dISA_K
       }
       
       return Measurement(value: T_K, unit: .kelvin)
   }
   
   /// Pressure at altitude (default uses instance altitude if nil). deltaISA same semantics as temperature().
   /// This computes pressure by chaining through bands from sea level up to the target altitude.
   public func pressure(at altitude: Measurement<UnitLength>? = nil,
                        deltaISA: Measurement<UnitTemperature>? = nil) -> Measurement<UnitPressure> {
       let target = (altitude ?? self.altitude) ?? ISA.troposphereBaseAltitude
       let target_m = target.converted(to: .meters).value
       let dISA_K = (deltaISA ?? self.deltaISA).converted(to: .kelvin).value
       
       // Start from sea level base values
       var P_base = ISA.seaLevelPressure.converted(to: .newtonsPerMetersSquared).value
       var h_base = ISA.troposphereBaseAltitude.meters
       var T_base = ISA.seaLevelTemperature.converted(to: .kelvin).value + dISA_K
       
       // segments in order
       let segments: [(band: Band, top_h: Double)] = [
           (.troposphere, ISA.tropopauseBaseAltitude.meters),
           (.tropopause, ISA.stratosphereBaseAltitude.meters),
           (.stratosphere, Double.infinity)
       ]
       
       for seg in segments {
           if target_m <= h_base { break } // already at/below base
           let segTop = seg.top_h
           let h_segTop = min(segTop, target_m)
           if h_segTop <= h_base { continue }
           
           let L = seg.band.lapseRate
           let T_base_seg = seg.band.baseTemperature_K + dISA_K
           let delta_h = h_segTop - h_base
           let P_at_top: Double
           if L == 0 {
               let exponent = -ISA.standardGravity.metersPerSecondSquared * delta_h / (ISA.dryAirGasConstant * T_base_seg)
               P_at_top = P_base * exp(exponent)
           } else {
               let T_at_top = T_base_seg + L * delta_h
               let exponent = -ISA.standardGravity.metersPerSecondSquared / (L * ISA.dryAirGasConstant)
               P_at_top = P_base * pow(T_at_top / T_base_seg, exponent)
           }
           
           if target_m <= segTop {
               return Measurement(value: P_at_top, unit: .newtonsPerMetersSquared)
           }
           
           // step into next segment
           P_base = P_at_top
           h_base = segTop
           T_base = seg.band.baseTemperature_K + dISA_K
       }
       // fallback
       return Measurement(value: P_base, unit: .newtonsPerMetersSquared)
   }
   
   /// Density using ρ = p / (R * T). Returned in g/L (to match earlier usage); 1 kg/m^3 = 1 g/L.
   public func density(at altitude: Measurement<UnitLength>? = nil,
                       deltaISA: Measurement<UnitTemperature>? = nil) -> Measurement<UnitConcentrationMass> {
       let pPa = pressure(at: altitude, deltaISA: deltaISA).converted(to: .newtonsPerMetersSquared).value
       let tK = temperature(at: altitude, deltaISA: deltaISA).converted(to: .kelvin).value
       let rho = pPa / (ISA.dryAirGasConstant * tK) // kg/m^3
       return Measurement(value: rho, unit: UnitConcentrationMass.gramsPerLiter)
   }
   
   /// Speed of sound: a = sqrt(gamma * R * T)
   public func speedOfSound(at altitude: Measurement<UnitLength>? = nil,
                            deltaISA: Measurement<UnitTemperature>? = nil) -> Measurement<UnitSpeed> {
       let tK = temperature(at: altitude, deltaISA: deltaISA).converted(to: .kelvin).value
       let a = sqrt(ISA.ratioSpecificHeats * ISA.dryAirGasConstant * tK)
       return Measurement(value: a, unit: UnitSpeed.metersPerSecond)
   }
}

public typealias ISA = InternationalStandardAthmosphere

