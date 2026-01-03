import Foundation

extension Latitude {
    public var isNorthernHemisphere: Bool {
        decimalDegrees > 0
    }

    public var isSouthernHemisphere: Bool {
        decimalDegrees < 0
    }
}

extension Latitude: CustomStringConvertible {
    public var description: String {
        let dms = degreesMinutesSeconds
        return dms.formatted(direction: direction.rawValue, isLongitude: false)
    }
}

extension Latitude {
    /// Coding keys for encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case decimalDegrees
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Double.self)
        self.init(decimalDegrees: value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(decimalDegrees)
    }
}
