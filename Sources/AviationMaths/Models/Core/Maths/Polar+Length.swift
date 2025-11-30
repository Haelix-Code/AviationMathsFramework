import Foundation
import GeodesySpherical

extension PolarVector where UnitType == UnitLength {
    public var lengthCartesianVector: CartesianVector<UnitLength> { asCartesianVector }
    public var length: Measurement<UnitLength> { magnitude }

    public func positionRelativeToDatum(_ datum: Position2D) -> Position2D {
        let start = Coordinate(position2D: datum)
        let end = start.destination(with: magnitude.value, bearing: angle.converted(to: .degrees).value)
        return Position2D(coordinate: end)
    }
}
