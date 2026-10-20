extension PolarVector: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(bearing.converted(to: .degrees).value)
        hasher.combine(magnitude.converted(to: UnitType.baseUnit()).value)
    }
}

/// Encodes the magnitude in `UnitType`'s base unit, so no unit needs to be `Codable`.
extension PolarVector: Codable {
    enum CodingKeys: String, CodingKey {
        case bearing, magnitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let bearingDegrees = try container.decode(Double.self, forKey: .bearing)
        let magnitudeValue = try container.decode(Double.self, forKey: .magnitude)
        self.init(
            bearing: .init(degrees: bearingDegrees),
            magnitude: .init(value: magnitudeValue, unit: UnitType.baseUnit())
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bearing.degrees, forKey: .bearing)
        try container.encode(magnitude.converted(to: UnitType.baseUnit()).value, forKey: .magnitude)
    }
}
