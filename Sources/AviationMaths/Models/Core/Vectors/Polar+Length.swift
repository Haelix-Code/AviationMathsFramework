import Foundation
import Vincenty

extension PolarVector where UnitType == UnitLength {
    public var lengthCartesianVector: LengthCartesianVector { asCartesianVector }
    public var length: Measurement<UnitLength> { magnitude }

    /// The point reached by travelling this vector from `datum` along a geodesic on the
    /// WGS-84 ellipsoid (Vincenty's direct solution).
    public func positionRelativeToDatum(_ datum: Position2D) -> Position2D {
        do {
            let solution = try Ellipsoid.wgs84.direct(
                from: GeodeticCoordinate(position2D: datum),
                distance: magnitude.meters,
                initialBearing: bearing.converted(to: .degrees).value
            )
            return Position2D(coordinate: solution.destination)
        } catch {
            // Vincenty's direct solution always converges, so this is non-finite input.
            preconditionFailure("Can't place \(magnitude) at \(bearing) from \(datum): \(error)")
        }
    }
}
