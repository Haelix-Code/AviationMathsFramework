import Foundation

public struct AltitudeContext: Sendable {
    public let groundElevation: Measurement<UnitLength>?
    public let qnh: Measurement<UnitPressure>?
    
    public let temperatureReferenceAltitude: Measurement<UnitLength>?
    public let temperatureAtReference: Measurement<UnitTemperature>?
    public let lapseRate: Double
    
    public init(
        groundElevation: Measurement<UnitLength>? = nil,
        qnh: Measurement<UnitPressure>? = nil,
        temperatureReferenceAltitude: Measurement<UnitLength>? = nil,
        temperatureAtReference: Measurement<UnitTemperature>? = nil,
        lapseRate: Double = ISA.lapseRate(at: .surface)
    ) {
        self.groundElevation = groundElevation
        self.qnh = qnh
        self.temperatureReferenceAltitude = temperatureReferenceAltitude
        self.temperatureAtReference = temperatureAtReference
        self.lapseRate = lapseRate
    }
    
    /// Calculate temperature at any altitude using the temperature model
    public func temperature(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature>? {
        guard let refAlt = temperatureReferenceAltitude,
              let refTemp = temperatureAtReference else {
            return nil
        }
        
        let deltaH = altitude.meters - refAlt.meters
        let tempAtAltitude = refTemp.kelvin + (lapseRate * deltaH)
        return .init(kelvin: tempAtAltitude)
    }
    
    /// Backwards compatibility: surface temperature
    /// Returns temperature at ground elevation if available
    public var surfaceTemperature: Measurement<UnitTemperature>? {
        guard let groundElev = groundElevation else { return nil }
        return temperature(at: groundElev)
    }
    
    /// Sea level temperature (temperature at MSL = 0m)
    public var seaLevelTemperature: Measurement<UnitTemperature>? {
        temperature(at: .surface)
    }
    
    // MARK: - ISA Context
    public static let standardISA = AltitudeContext(
        groundElevation: .surface,
        qnh: ISA.seaLevelPressure,
        temperatureReferenceAltitude: .surface,
        temperatureAtReference: ISA.seaLevelTemperature,
        lapseRate: ISA.lapseRate(at: .surface)
    )
}
