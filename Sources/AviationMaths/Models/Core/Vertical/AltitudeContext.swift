import Foundation

public struct AltitudeContext: Sendable {
    public let groundElevation: Measurement<UnitLength>?
    public let qnh: Measurement<UnitPressure>?
    public let surfaceTemperature: Measurement<UnitTemperature>?
    public let lapseRate: Double
    
    public init(
        groundElevation: Measurement<UnitLength>? = nil,
        qnh: Measurement<UnitPressure>? = nil,
        surfaceTemperature: Measurement<UnitTemperature>? = nil,
        lapseRate: Double = ISA.lapseRateTroposphere
    ) {
        self.groundElevation = groundElevation
        self.qnh = qnh
        self.surfaceTemperature = surfaceTemperature
        self.lapseRate = lapseRate
    }
    
    public static let standardISA = AltitudeContext(
        groundElevation: Measurement(value: 0, unit: .meters),
        qnh: Measurement(value: 1013.25, unit: .hectopascals),
        surfaceTemperature: Measurement(value: 15, unit: .celsius),
        lapseRate: ISA.lapseRateTroposphere
    )
}
