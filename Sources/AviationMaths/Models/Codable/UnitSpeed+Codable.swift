import Foundation

public struct CodableSpeed: Codable, Equatable, Sendable {
    public let raw: Measurement<UnitSpeed>

    public init(_ raw: Measurement<UnitSpeed>) {
        self.raw = raw
    }

    private static let decodeMap: [String: UnitSpeed] = [
        "kt": .knots, "kts": .knots, "kn": .knots, "knot": .knots, "knots": .knots,
        "m/s": .metersPerSecond, "mps": .metersPerSecond,
        "km/h": .kilometersPerHour, "kph": .kilometersPerHour,
        "fps": .feetPerSecond,
        "mph": .milesPerHour
    ]

    private static let encodeNames: [UnitSpeed: String] = [
        .knots: "knots",
        .metersPerSecond: "m/s",
        .kilometersPerHour: "km/h",
        .feetPerSecond: "fps",
        .milesPerHour: "mph"
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

        // A unit decode wouldn't recognise is written in m/s instead, so every
        // encoded value can be decoded back.
        guard let name = Self.encodeNames[raw.unit] else {
            try c.encode(raw.mps, forKey: .value)
            try c.encode("m/s", forKey: .unit)
            return
        }
        try c.encode(raw.value, forKey: .value)
        try c.encode(name, forKey: .unit)
    }
}

public extension CodableSpeed {
    var measurement: Measurement<UnitSpeed> { raw }
}
