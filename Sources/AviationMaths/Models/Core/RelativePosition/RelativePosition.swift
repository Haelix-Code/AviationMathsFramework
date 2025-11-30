import Foundation

public struct RelativePosition {
    public let vector2D: LengthCartesianVector
    public var polarCoordinate: LengthPolar

    public init(angle: Measurement<UnitAngle>, range: Measurement<UnitLength>) {
        self.polarCoordinate = PolarVector(angle: angle, magnitude: range)
        self.vector2D = polarCoordinate.asCartesianVector
    }

    public init(x: Measurement<UnitLength>, y: Measurement<UnitLength>) {
        self.vector2D = CartesianVector(x: x, y: y)
        self.polarCoordinate = vector2D.asPolar
    }

    public init(vector2D: LengthCartesianVector) {
        self.vector2D = vector2D
        self.polarCoordinate = vector2D.asPolar
    }

    public init(polarCoordinate: LengthPolar) {
        self.polarCoordinate = polarCoordinate
        self.vector2D = polarCoordinate.asCartesianVector
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
