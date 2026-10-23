import Foundation
import Vincenty

extension PolarVector where UnitType == UnitLength {
    public var lengthCartesianVector: LengthCartesianVector { asCartesianVector }
    public var length: Measurement<UnitLength> { magnitude }

    /// The point reached by travelling this vector from `datum` along a geodesic on the
    /// WGS-84 ellipsoid (Vincenty's direct solution).
    /// - Precondition: The vector's magnitude and bearing are finite. NaN or infinity here is a
    ///   programmer error (like integer overflow), so validate user input before building vectors.
    public func positionRelativeToDatum(_ datum: Position2D) -> Position2D {
        do {
            let solution = try Ellipsoid.wgs84.direct(
                from: GeodeticCoordinate(position2D: datum),
                distance: magnitude.meters,
                initialBearing: bearing.converted(to: .degrees).value
            )
            return try Position2D(coordinate: solution.destination)
        } catch {
            // Vincenty's direct solution always converges and stays on the ellipsoid, so this
            // is non-finite input.
            preconditionFailure("Can't place \(magnitude) at \(bearing) from \(datum): \(error)")
        }
    }
}
