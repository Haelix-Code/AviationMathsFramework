import Foundation

public struct AltitudeContext: Sendable {
    public let groundElevation: Measurement<UnitLength>?
    public let qnh: Measurement<UnitPressure>?
    
    public let surfaceTemperature: Measurement<UnitTemperature>?
    public let temperatureReferenceAltitude: Measurement<UnitLength>?
    public let temperatureAtReference: Measurement<UnitTemperature>?
    
    public let lapseRate: Double?
    
    public init(
        groundElevation: Measurement<UnitLength>? = nil,
        qnh: Measurement<UnitPressure>? = nil,
        surfaceTemperature: Measurement<UnitTemperature>? = nil,
        temperatureReferenceAltitude: Measurement<UnitLength>? = nil,
        temperatureAtReference: Measurement<UnitTemperature>? = nil,
        lapseRate: Double? = nil
    ) {
        self.groundElevation = groundElevation
        self.qnh = qnh
        self.surfaceTemperature = surfaceTemperature
        self.temperatureReferenceAltitude = temperatureReferenceAltitude
        self.temperatureAtReference = temperatureAtReference
        
        // Calculate lapse rate if not provided but we have the data
        if let lapseRate = lapseRate {
            self.lapseRate = lapseRate
        } else if let surfaceTemp = surfaceTemperature,
                  let altTemp = temperatureAtReference,
                  let tempAlt = temperatureReferenceAltitude,
                  let elev = groundElevation {
            // Lapse rate = -(T_alt - T_surface) / (h_alt - h_surface)
            let temperatureDifference = altTemp.kelvin - surfaceTemp.kelvin
            let altitudeDifference = tempAlt.meters - elev.meters
            self.lapseRate = -temperatureDifference / altitudeDifference
        } else {
            self.lapseRate = nil
        }
    }
    
    /// Calculate sea level temperature from surface temperature and ground elevation
    /// Used for true altitude conversions
    public var seaLevelTemperature: Measurement<UnitTemperature>? {
        guard let surfaceTemp = surfaceTemperature,
              let elev = groundElevation,
              let rate = lapseRate else {
            return nil
        }
        // T_sl = T_surface + L * h_surface
        let tempAtSeaLevel = surfaceTemp.celsius + rate * elev.meters
        return .init(celsius: tempAtSeaLevel)
    }
    
    /// Calculate temperature at any altitude using the temperature model
    public func temperature(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature>? {
        guard let surfaceTemp = surfaceTemperature,
              let elev = groundElevation,
              let rate = lapseRate else {
            return nil
        }
        
        let deltaH = altitude.meters - elev.meters
        let tempAtAlt = surfaceTemp.kelvin - (rate * deltaH)
        return .init(kelvin: tempAtAlt)
    }
    
    public static let standardISA = AltitudeContext(
        groundElevation: .surface,
        qnh: ISA.seaLevelPressure,
        surfaceTemperature: ISA.seaLevelTemperature,
        lapseRate: ISA.troposphereLapseRate
    )
}

extension AltitudeContext {
    public static func calculateLapseRate(
        surfaceTemp: Measurement<UnitTemperature>,
        tempAtAltitude: Measurement<UnitTemperature>,
        altitude: Measurement<UnitLength>,
        groundElevation: Measurement<UnitLength>
    ) -> Double {
        let temperatureDifference = tempAtAltitude.kelvin - surfaceTemp.kelvin
        let altitudeDifference = altitude.meters - groundElevation.meters
        return -temperatureDifference / altitudeDifference
    }
}
