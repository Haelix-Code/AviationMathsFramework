import Foundation
import GeodesySpherical

public struct PolarVector<Magnitude: Equatable>: Equatable {
    public let angle: Measurement<UnitAngle>
    public let magnitude: Magnitude

    public init(angle: Measurement<UnitAngle>, magnitude: Magnitude) {
        self.angle = angle
        self.magnitude = magnitude
    }
}

extension PolarVector where Magnitude == Measurement<UnitLength> {
    public var vector2D: Vector2D {
        return .init(x: .init(meters: magnitude.meters * sin(angle.radians)),
                     y: .init(meters: magnitude.meters * cos(angle.radians)))
    }

    public var range: Measurement<UnitLength> { self.magnitude }
    
    public func positionRelativeToDatum(_ datum: Position2D) -> Position2D {
        let startPoint = Coordinate(position2D: datum)
        let endPoint = startPoint.destination(with: magnitude.meters, bearing: angle.degrees)
        return Position2D(coordinate: endPoint)
    }

    public func description() -> String {
        if angle.degrees.isNaN {
            return "--"
        } else {
            return "\(angle.degrees) \(range.converted(to: .nauticalMiles).value)"
        }
    }

}

extension PolarVector where Magnitude == Measurement<UnitSpeed> {
    public var vector2D: Vector2D {
        return .init(x: .init(meters: magnitude.mps * sin(angle.radians)),
                     y: .init(meters: magnitude.mps * cos(angle.radians)))
    }
    public var speed: Measurement<UnitSpeed> { self.magnitude }
}

public typealias DistanceVector = PolarVector<Measurement<UnitLength>>
public typealias SpeedVector = PolarVector<Measurement<UnitSpeed>>
