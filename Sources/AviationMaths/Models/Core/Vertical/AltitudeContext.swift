import Foundation

public struct AltitudeContext: Sendable {
    public let groundElevation: Measurement<UnitLength>?
    public let qnh: Measurement<UnitPressure>?
    
    private let _surfaceTemperature: Measurement<UnitTemperature>?
    private let _seaLevelTemperature: Measurement<UnitTemperature>?
    
    public let temperatureReferenceAltitude: Measurement<UnitLength>?
    public let temperatureAtReference: Measurement<UnitTemperature>?
    
    public let lapseRate: Double?
    
    /// Surface temperature (at ground elevation)
    public var surfaceTemperature: Measurement<UnitTemperature>? {
        if let temp = _surfaceTemperature {
            return temp
        }
        // Calculate from sea level temperature if available
        guard let slTemp = _seaLevelTemperature,
              let elev = groundElevation,
              let rate = lapseRate else {
            return nil
        }
        // T_surface = T_sl - L * h_elevation
        let surfaceTemp = slTemp.kelvin - rate * elev.meters
        return .init(kelvin: surfaceTemp)
    }
    
    /// Sea level temperature (at height = 0)
    public var seaLevelTemperature: Measurement<UnitTemperature>? {
        if let temp = _seaLevelTemperature {
            return temp
        }
        // Calculate from surface temperature if available
        guard let surfTemp = _surfaceTemperature,
              let elev = groundElevation,
              let rate = lapseRate else {
            return nil
        }
        // T_sl = T_surface + L * h_elevation
        let slTemp = surfTemp.kelvin + rate * elev.meters
        return .init(kelvin: slTemp)
    }
    
    public init(
        groundElevation: Measurement<UnitLength>? = nil,
        qnh: Measurement<UnitPressure>? = nil,
        surfaceTemperature: Measurement<UnitTemperature>? = nil,
        seaLevelTemperature: Measurement<UnitTemperature>? = nil,
        temperatureReferenceAltitude: Measurement<UnitLength>? = nil,
        temperatureAtReference: Measurement<UnitTemperature>? = nil,
        lapseRate: Double? = nil
    ) {
        self.groundElevation = groundElevation
        self.qnh = qnh
        self._surfaceTemperature = surfaceTemperature
        self._seaLevelTemperature = seaLevelTemperature
        self.temperatureReferenceAltitude = temperatureReferenceAltitude
        self.temperatureAtReference = temperatureAtReference
        
        // Calculate lapse rate if not provided but we have the data
        if let lapseRate = lapseRate {
            self.lapseRate = lapseRate
        } else if let surfTemp = surfaceTemperature,
                  let altTemp = temperatureAtReference,
                  let tempAlt = temperatureReferenceAltitude,
                  let elev = groundElevation {
            // Lapse rate = (T_surface - T_alt) / (h_alt - h_surface)
            // Note: this is positive when temperature decreases with altitude
            let temperatureDifference = surfTemp.kelvin - altTemp.kelvin
            let altitudeDifference = tempAlt.meters - elev.meters
            self.lapseRate = temperatureDifference / altitudeDifference
        } else if let slTemp = seaLevelTemperature,
                  let altTemp = temperatureAtReference,
                  let tempAlt = temperatureReferenceAltitude {
            // Calculate from sea level
            let temperatureDifference = slTemp.kelvin - altTemp.kelvin
            let altitudeDifference = tempAlt.meters - 0  // sea level is at 0
            self.lapseRate = temperatureDifference / altitudeDifference
        } else {
            self.lapseRate = nil
        }
    }
    
    /// Calculate temperature at any altitude using the temperature model
    public func temperature(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature>? {
        guard let slTemp = seaLevelTemperature,
              let rate = lapseRate else {
            return nil
        }
        
        // T = T_sl - L * h
        let tempAtAlt = slTemp.kelvin - rate * altitude.meters
        return .init(kelvin: tempAtAlt)
    }
    
    public static let standardISA = AltitudeContext(
        groundElevation: .surface,
        qnh: ISA.seaLevelPressure,
        seaLevelTemperature: ISA.seaLevelTemperature,
        lapseRate: ISA.troposphereLapseRate
    )
}

extension AltitudeContext {
    /// Calculate lapse rate from two temperature measurements
    public static func calculateLapseRate(
        tempAtLowerAltitude: Measurement<UnitTemperature>,
        tempAtHigherAltitude: Measurement<UnitTemperature>,
        lowerAltitude: Measurement<UnitLength>,
        higherAltitude: Measurement<UnitLength>
    ) -> Double {
        let temperatureDifference = tempAtLowerAltitude.kelvin - tempAtHigherAltitude.kelvin
        let altitudeDifference = higherAltitude.meters - lowerAltitude.meters
        return temperatureDifference / altitudeDifference
    }
}
