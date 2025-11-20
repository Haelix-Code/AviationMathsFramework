import Foundation

/// Represents a wind measurement at a specific altitude.
///
/// Wind is defined using meteorological convention where direction indicates
/// where the wind is **coming from** (not going to).
public struct Wind: Equatable, Sendable {
    public let altitude: Measurement<UnitLength>
    public let direction: Measurement<UnitAngle>
    public let speed: Measurement<UnitSpeed>

    public init(
        altitude: Measurement<UnitLength>,
        direction: Measurement<UnitAngle>,
        speed: Measurement<UnitSpeed>
    ) {
        self.altitude = altitude
        self.direction = direction
        self.speed = speed
    }
}

// MARK: - Wind Components

public extension Wind {
    func components(relativeTo track: Measurement<UnitAngle>) -> WindComponents {
        let windAngle = direction.radians
        let trackAngle = track.radians
        let angleDifference = windAngle - trackAngle

        let windSpeedValue = speed.mps
        let headwindValue = windSpeedValue * cos(angleDifference)
        let crosswindValue = windSpeedValue * sin(angleDifference)

        return WindComponents(
            headwind: .init(mps: headwindValue),
            crosswind: .init(mps: crosswindValue)
        )
    }
}

public extension Wind {
    func groundSpeed(
        trueAirspeed: Measurement<UnitSpeed>,
        track: Measurement<UnitAngle>
    ) -> Measurement<UnitSpeed> {
        let components = self.components(relativeTo: track)
        return .init(mps: trueAirspeed.mps - components.headwind.mps)
    }
}

public struct WindComponents: Equatable, Sendable {
    public let headwind: Measurement<UnitSpeed>
    public let crosswind: Measurement<UnitSpeed>

    public init(headwind: Measurement<UnitSpeed>, crosswind: Measurement<UnitSpeed>) {
        self.headwind = headwind
        self.crosswind = crosswind
    }
}

extension Wind: Encodable {
    enum CodingKeys: String, CodingKey {
        case altitude
        case direction
        case speed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(altitude.meters, forKey: .altitude)
        try container.encode(direction.degrees, forKey: .direction)
        try container.encode(speed.mps, forKey: .speed)
    }
}

extension Wind: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let altitudeMeters = try container.decode(Double.self, forKey: .altitude)
        let directionDegrees = try container.decode(Double.self, forKey: .direction)
        let speedMPS = try container.decode(Double.self, forKey: .speed)

        self.altitude = .init(meters: altitudeMeters)
        self.direction = .init(degrees: directionDegrees)
        self.speed = .init(mps: speedMPS)
    }
}
