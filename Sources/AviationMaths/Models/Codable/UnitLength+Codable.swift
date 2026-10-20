import Foundation

public struct CodableLength: Codable, Equatable, Sendable {
    public let raw: Measurement<UnitLength>

    public init(_ raw: Measurement<UnitLength>) {
        self.raw = raw
    }

    private static let decodeMap: [String: UnitLength] = [
        "m": .meters, "meter": .meters, "meters": .meters,
        "ft": .feet, "foot": .feet, "feet": .feet,
        "yd": .yards, "yard": .yards, "yards": .yards,
        "nm": .nauticalMiles, "nmi": .nauticalMiles,
        "nauticalmile": .nauticalMiles, "nauticalmiles": .nauticalMiles,
        "km": .kilometers, "kilometer": .kilometers, "kilometers": .kilometers,
        "mi": .miles, "mile": .miles, "miles": .miles
    ]

    private static let encodeNames: [UnitLength: String] = [
        .meters: "m",
        .feet: "ft",
        .yards: "yd",
        .nauticalMiles: "nm",
        .kilometers: "km",
        .miles: "mi"
    ]

    enum CodingKeys: String, CodingKey {
        case value
        case unit
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let value = try c.decode(Double.self, forKey: .value)
        let unitString = try c.decode(String.self, forKey: .unit).lowercased()

        guard let unit = Self.decodeMap[unitString] else {
            throw DecodingError.dataCorruptedError(
                forKey: .unit,
                in: c,
                debugDescription: "Unknown length unit: \(unitString)"
            )
        }

        raw = Measurement(value: value, unit: unit)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)

        // A unit decode wouldn't recognise is written in metres instead, so every
        // encoded value can be decoded back.
        guard let name = Self.encodeNames[raw.unit] else {
            try c.encode(raw.meters, forKey: .value)
            try c.encode("m", forKey: .unit)
            return
        }
        try c.encode(raw.value, forKey: .value)
        try c.encode(name, forKey: .unit)
    }
}

extension CodableLength {
    public var measurement: Measurement<UnitLength> { raw }
}
