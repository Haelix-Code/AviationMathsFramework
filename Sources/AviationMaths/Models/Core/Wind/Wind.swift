import Foundation

public struct Wind: Equatable, Sendable {
    public let altitude: Measurement<UnitLength>
    public let fromDirection: Measurement<UnitAngle>        // Direction from which the wind is blowing
    public let speed: Measurement<UnitSpeed>

    public init(
        altitude: Measurement<UnitLength>,
        fromDirection: Measurement<UnitAngle>,
        speed: Measurement<UnitSpeed>
    ) {
        self.altitude = altitude
        self.fromDirection = fromDirection
        self.speed = speed
    }
    
    var toDirection: Measurement<UnitAngle> {
        var deg = fromDirection.degrees + 180
        deg.formTruncatingRemainder(dividingBy: 360)
        return .init(degrees: deg)
    }
    
    var vector: SpeedCartesianVector {
           // Wind bearing in degrees (from North)
           let toDirectionDeg = (fromDirection.degrees + 180).truncatingRemainder(dividingBy: 360)
           let angleRad = toDirectionDeg * .pi / 180

           // Convert to Cartesian: x = east, y = north
           return CartesianVector(
               x: .init(value: speed.value * sin(angleRad), unit: speed.unit),
               y: .init(value: speed.value * cos(angleRad), unit: speed.unit)
           )
       }

    var polar: SpeedPolar {
        let angleRad = (.pi / 180) * (90 - toDirection.degrees) // 0 rad along +x, CCW
        return SpeedPolar(angle: .init(value: angleRad, unit: .radians), magnitude: speed)
    }
}

public extension Wind {
    init(feet: Double, knots: Double, bearing: Double) {
        self.altitude = .init(feet: feet)
        self.fromDirection = .init(degrees: bearing)
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
