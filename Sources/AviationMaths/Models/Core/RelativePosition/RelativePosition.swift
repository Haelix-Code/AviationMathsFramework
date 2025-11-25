import Foundation

public struct RelativePosition {
    public let polarCoordinate: PolarVector<Measurement<UnitLength>>

    public var vector2D: Vector2D {
        polarCoordinate.vector2D
    }

    public init(angle: Measurement<UnitAngle>, range: Measurement<UnitLength>) {
        self.polarCoordinate = PolarVector(angle: angle, magnitude: range)
    }

    public init(x: Measurement<UnitLength>, y: Measurement<UnitLength>) {
        let vector = Vector2D(x: x, y: y)
        self.polarCoordinate = vector.polarCoordinate
    }

    public init(vector2D: Vector2D) {
        self.polarCoordinate = vector2D.polarCoordinate
    }

    public init(polarCoordinate: PolarVector<Measurement<UnitLength>>) {
        self.polarCoordinate = polarCoordinate
    }

    public var perpendicularAngles: [Measurement<UnitAngle>] {
        polarCoordinate.angle.perpendicularAngles
    }

    public var angle: Measurement<UnitAngle> {
        polarCoordinate.angle
    }

    public var range: Measurement<UnitLength> {
        polarCoordinate.magnitude
    }

    public var x: Measurement<UnitLength> {
        vector2D.x
    }

    public var y: Measurement<UnitLength> {
        vector2D.y
    }
}

extension RelativePosition: Equatable {
    public static func == (lhs: RelativePosition, rhs: RelativePosition) -> Bool {
        lhs.vector2D == rhs.vector2D
    }
}

extension RelativePosition: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(vector2D)
    }
}

extension RelativePosition: CustomStringConvertible {
    public var description: String {
        "RelativePosition(x: \(x), y: \(y)) [angle: \(angle), range: \(range)]"
    }
}
