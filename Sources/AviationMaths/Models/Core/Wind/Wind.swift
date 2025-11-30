import Foundation

public struct Wind: Equatable, Sendable {
    public let altitude: Measurement<UnitLength>
    public let fromDirection: Measurement<UnitAngle> // Direction wind blows FROM
    public let speed: Measurement<UnitSpeed>

    public init(
        altitude: Measurement<UnitLength>,
        fromDirection: Measurement<UnitAngle>,
        speed: Measurement<UnitSpeed>
    ) {
        self.altitude = altitude
        self.fromDirection = fromDirection.normalized
        self.speed = speed
    }
    
    /// Direction wind is blowing TO (opposite of fromDirection)
    public var toDirection: Measurement<UnitAngle> {
        Measurement(value: fromDirection.degrees + 180, unit: .degrees).normalized
    }
    
    /// Wind as a velocity vector (direction = where wind is going)
    public var vector: SpeedCartesianVector {
        // Polar with bearing = toDirection (where wind pushes things)
        let polar = SpeedPolar(bearing: toDirection, magnitude: speed)
        return polar.asCartesianVector
    }

    /// Wind as a polar vector
    public var polar: SpeedPolar {
        SpeedPolar(bearing: toDirection, magnitude: speed)
    }
}

public extension Wind {
    init(feet: Double, knots: Double, bearingFrom: Double) {
        self.altitude = .init(feet: feet)
        self.fromDirection = .init(degrees: bearingFrom)
        self.speed = .init(knots: knots)
    }
}

extension Wind: Encodable {
    enum CodingKeys: String, CodingKey {
        case altitude
        case fromDirection
        case speed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(altitude.meters, forKey: .altitude)
        try container.encode(fromDirection.degrees, forKey: .fromDirection)
        try container.encode(speed.mps, forKey: .speed)
    }
}

extension Wind: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let altitudeMeters = try container.decode(Double.self, forKey: .altitude)
        let directionDegrees = try container.decode(Double.self, forKey: .fromDirection)
        let speedMPS = try container.decode(Double.self, forKey: .speed)

        self.altitude = .init(meters: altitudeMeters)
        self.fromDirection = .init(degrees: directionDegrees)
        self.speed = .init(mps: speedMPS)
    }
}
