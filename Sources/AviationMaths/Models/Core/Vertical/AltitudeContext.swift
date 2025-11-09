import Foundation

public struct AltitudeContext: Sendable {
    public let groundElevation: Measurement<UnitLength>?
    public let qnh: Measurement<UnitPressure>?
    
    public let surfaceTemperature: Measurement<UnitTemperature>?
    public let altitudeForTemperature: Measurement<UnitLength>?
    public let temperatureAtReference: Measurement<UnitTemperature>?
    
    public let lapseRate: Double?
    
    public init(
        groundElevation: Measurement<UnitLength>? = nil,
        qnh: Measurement<UnitPressure>? = nil,
        surfaceTemperature: Measurement<UnitTemperature>? = nil,
        altitudeForTemperature: Measurement<UnitLength>? = nil,
        temperatureAtReference: Measurement<UnitTemperature>? = nil,
        lapseRate: Double? = nil
    ) {
        self.groundElevation = groundElevation
        self.qnh = qnh
        self.surfaceTemperature = surfaceTemperature
        self.altitudeForTemperature = altitudeForTemperature
        self.temperatureAtReference = temperatureAtReference
        
        if let lapseRate = lapseRate {
            self.lapseRate = lapseRate
        } else if let surfaceTemp = surfaceTemperature,
                  let altTemp = temperatureAtReference,
                  let tempAlt = altitudeForTemperature,
                  let elev = groundElevation {
            let temperatureDifference = altTemp.kelvin - surfaceTemp.kelvin
            let altitudeDifference = tempAlt.meters - elev.meters
            self.lapseRate = -temperatureDifference / altitudeDifference
        } else {
            self.lapseRate = nil
        }
                    
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
        lapseRate: -ISA.troposphereLapseRate // ISA uses positive lapse rate value
    )
}
