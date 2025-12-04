import Foundation
import GeodesySpherical

public extension CartesianVector where UnitType == UnitLength {
    var lengthPolar: LengthPolar { asPolar }
    var length: Measurement<UnitLength> { magnitude }

    func positionRelativeToDatum(_ datum: Position2D) -> Position2D {
        let polar = self.asPolar
        let start = Coordinate(position2D: datum)
        let end = start.destination(
            with: polar.magnitude.meters,
            bearing: polar.bearing.converted(to: .degrees).value
        )
        return Position2D(coordinate: end)
    }
}
