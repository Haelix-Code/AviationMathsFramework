import Foundation

public struct ValidatedAltitudeContext: Sendable, Equatable, Codable {
    public let raw: AltitudeContext

    public let groundElevation: Measurement<UnitLength>
    public let qnh: Measurement<UnitPressure>
    public let lapseRate: Double
    public let seaLevelTemperature: Measurement<UnitTemperature>
    public let surfaceTemperature: Measurement<UnitTemperature>

    /// - Throws: `AltitudeConversionError` for the first thing `ctx` is missing: ground elevation,
    ///   QNH, or a temperature profile (lapse rate, and a sea-level or surface temperature).
    public init(_ ctx: AltitudeContext) throws(AltitudeConversionError) {
        guard let groundElevation = ctx.groundElevation else {
            throw .missingGroundElevation
        }
        guard let qnh = ctx.qnh else {
            throw .missingQNH
        }
        guard let lapseRate = ctx.lapseRate,
              let slt = try? ctx.seaLevelTemperature,
              let sft = try? ctx.surfaceTemperature else {
            throw .missingTemperatureProfile
        }

        self.raw = ctx
        self.groundElevation = groundElevation
        self.qnh = qnh
        self.lapseRate = lapseRate
        self.seaLevelTemperature = slt
        self.surfaceTemperature = sft
    }

    /// Decoding re-validates `raw`, so a decoded context keeps the guarantee that every
    /// conversion succeeds.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let raw = try container.decode(AltitudeContext.self, forKey: .raw)
        do {
            try self.init(raw)
        } catch {
            throw DecodingError.dataCorruptedError(
                forKey: .raw,
                in: container,
                debugDescription: "Context isn't complete: \(error)"
            )
        }
    }
}

extension AltitudeContext {
    public var validated: ValidatedAltitudeContext? {
        try? ValidatedAltitudeContext(self)
    }

    public var isComplete: Bool {
        groundElevation != nil &&
        qnh != nil &&
        (try? seaLevelTemperature) != nil &&
        (try? surfaceTemperature) != nil &&
        lapseRate != nil
    }

}
