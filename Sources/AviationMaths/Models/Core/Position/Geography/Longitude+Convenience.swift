extension Longitude {
    public var isEasternHemisphere: Bool {
        decimalDegrees > 0
    }

    public var isWesternHemisphere: Bool {
        decimalDegrees < 0
    }

    public var normalized: Longitude {
        var normalized = decimalDegrees

        // Wrap to -180 to +180
        while normalized > 180 {
            normalized -= 360
        }
        while normalized < -180 {
            normalized += 360
        }

        return Longitude(decimalDegrees: normalized)
    }

    public var as0To360: Double {
        decimalDegrees < 0 ? decimalDegrees + 360 : decimalDegrees
    }
}

extension Longitude {
    public func shortestDistance(to other: Longitude) -> Double {
        var delta = other.decimalDegrees - decimalDegrees

        if delta > 180 {
            delta -= 360
        } else if delta < -180 {
            delta += 360
        }

        return delta
    }
}

extension Longitude: CustomStringConvertible {
    public var description: String {
        let dms = degreesMinutesSeconds
        return dms.formatted(direction: direction.rawValue, isLongitude: true)
    }
}

extension Longitude {
    /// Coding keys for encoding/decoding
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
