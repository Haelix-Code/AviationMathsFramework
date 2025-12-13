import Foundation

public struct CodableSpeed: Codable, Equatable, Sendable {
    public let raw: Measurement<UnitSpeed>

    public init(_ raw: Measurement<UnitSpeed>) {
        self.raw = raw
    }

    private static let decodeMap: [String: UnitSpeed] = [
        "kt": .knots, "kts": .knots, "knot": .knots, "knots": .knots,
        "m/s": .metersPerSecond, "mps": .metersPerSecond,
        "km/h": .kilometersPerHour, "kph": .kilometersPerHour,
        "fps": .feetPerSecond
    ]

    private static let encodeNames: [UnitSpeed: String] = [
        .knots: "knots",
        .metersPerSecond: "m/s",
        .kilometersPerHour: "km/h",
        .feetPerSecond: "fps"
    ]

    private enum CodingKeys: String, CodingKey {
        case unit, value
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let value = try c.decode(Double.self, forKey: .value)

        let unitString = try c.decode(String.self, forKey: .unit)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard let unit = Self.decodeMap[unitString] else {
            throw DecodingError.dataCorruptedError(
                forKey: .unit, in: c,
                debugDescription: "Unknown speed unit: \(unitString)"
            )
        }

        raw = Measurement(value: value, unit: unit)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(raw.value, forKey: .value)

        let name = Self.encodeNames[raw.unit] ?? raw.unit.symbol
        try c.encode(name, forKey: .unit)
    }
}

public extension CodableSpeed {
    var measurement: Measurement<UnitSpeed> { raw }
}
