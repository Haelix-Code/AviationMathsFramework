import Foundation

public struct Wind: Equatable, Sendable {
    public let altitude: Measurement<UnitLength> // AMSL
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

extension Wind: Codable {

    private struct Scalar: Codable { let value: Double; let unit: String }

    private enum UnitKeys: String, CodingKey { case altitude, speed, direction }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: UnitKeys.self)

        let a = try c.decode(Scalar.self, forKey: .altitude)
        let s = try c.decode(Scalar.self, forKey: .speed)
        let d = try c.decode(Scalar.self, forKey: .direction)

        altitude = (a.unit == "ft") ? .init(feet: a.value) : .init(meters: a.value)
        speed    = (s.unit == "kn") ? .init(knots: s.value) : .init(mps: s.value)
        fromDirection = .init(degrees: d.value).normalized
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: UnitKeys.self)
        try c.encode(Scalar(value: altitude.converted(to: .feet).value, unit: "ft"), forKey: .altitude)
        try c.encode(Scalar(value: speed.converted(to: .knots).value, unit: "kn"), forKey: .speed)
        try c.encode(Scalar(value: fromDirection.degrees, unit: "°"), forKey: .direction)
    }
}

