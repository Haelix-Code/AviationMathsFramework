import Foundation

public extension CartesianVector where UnitType == UnitLength {
    var lengthPolar: LengthPolar { asPolar }
    var length: Measurement<UnitLength> { magnitude }

    /// The point reached by travelling this vector from `datum` along a geodesic on the
    /// WGS-84 ellipsoid.
    func positionRelativeToDatum(_ datum: Position2D) -> Position2D {
        asPolar.positionRelativeToDatum(datum)
    }
}
