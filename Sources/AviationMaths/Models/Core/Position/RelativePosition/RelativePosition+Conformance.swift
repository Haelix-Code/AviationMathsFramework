extension RelativePosition: Equatable {
    public static func == (lhs: RelativePosition, rhs: RelativePosition) -> Bool {
        lhs.cartesianVector == rhs.cartesianVector
    }
}

extension RelativePosition: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cartesianVector)
    }
}

extension RelativePosition: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let xMeters = try container.decode(Double.self, forKey: .x)
        let yMeters = try container.decode(Double.self, forKey: .y)
        self.init(x: .init(meters: xMeters), y: .init(meters: yMeters))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x.meters, forKey: .x)
        try container.encode(y.meters, forKey: .y)
    }
}
