import Foundation

public struct ValidatedAltitudeContext: Sendable, Equatable, Codable {
    public let raw: AltitudeContext

    public let groundElevation: Measurement<UnitLength>
    public let qnh: Measurement<UnitPressure>
    public let lapseRate: Double
    public let seaLevelTemperature: Measurement<UnitTemperature>
    public let surfaceTemperature: Measurement<UnitTemperature>

    public init(_ ctx: AltitudeContext) {
        guard let groundElevation = ctx.groundElevation else {
            fatalError("AltitudeContext missing groundElevation")
        }
        guard let qnh = ctx.qnh else {
            fatalError("AltitudeContext missing QNH")
        }
        guard let lapseRate = ctx.lapseRate else {
            fatalError("AltitudeContext missing lapseRate")
        }
        guard let slt = ctx.seaLevelTemperature else {
            fatalError("AltitudeContext missing sea-level temperature")
        }
        guard let sft = ctx.surfaceTemperature else {
            fatalError("AltitudeContext missing surface temperature")
        }

        self.raw = ctx
        self.groundElevation = groundElevation
        self.qnh = qnh
        self.lapseRate = lapseRate
        self.seaLevelTemperature = slt
        self.surfaceTemperature = sft
    }
}

extension AltitudeContext {
    public var validated: ValidatedAltitudeContext? {
        guard isComplete else { return nil }
        return ValidatedAltitudeContext(self)
    }

    public var isComplete: Bool {
        groundElevation != nil &&
        qnh != nil &&
        seaLevelTemperature != nil &&
        surfaceTemperature != nil &&
        lapseRate != nil
    }

}
