import Foundation

public struct RelativePosition: Sendable {
    public let cartesianVector: LengthCartesianVector
    public var polarCoordinate: LengthPolar

    public init(bearing: Measurement<UnitAngle>, range rangeValue: Measurement<UnitLength>) {
        self.polarCoordinate = PolarVector(bearing: bearing, magnitude: rangeValue)
        self.cartesianVector = polarCoordinate.asCartesianVector
    }

    public init(x: Measurement<UnitLength>, y: Measurement<UnitLength>) {
        self.cartesianVector = CartesianVector(x: x, y: y)
        self.polarCoordinate = cartesianVector.asPolar
    }

    public init(cartesianVector: LengthCartesianVector) {
        self.cartesianVector = cartesianVector
        self.polarCoordinate = cartesianVector.asPolar
    }

    public init(polarCoordinate: LengthPolar) {
        self.polarCoordinate = polarCoordinate
        self.cartesianVector = polarCoordinate.asCartesianVector
    }

    public var reciprocalBearing: Measurement<UnitAngle> {
        bearing.reciprocal
    }

    public var perpendiculars: (Measurement<UnitAngle>, Measurement<UnitAngle>) {
        polarCoordinate.bearing.perpendiculars
    }

    public var bearing: Measurement<UnitAngle> {
        polarCoordinate.bearing
    }

    public var range: Measurement<UnitLength> {
        polarCoordinate.magnitude
    }

    public var x: Measurement<UnitLength> {
        cartesianVector.x
    }

    public var y: Measurement<UnitLength> {
        cartesianVector.y
    }
}

public extension RelativePosition {
    /// Convert this relative position into a geodetic Position2D, using a datum.
    ///
    /// - Parameter datum: The reference position (e.g. DZ).
    /// - Returns: The resulting Position2D after applying this vector to the datum.
    func position(relativeTo datum: Position2D) -> Position2D {
        cartesianVector.positionRelativeToDatum(datum)
    }
}

public extension RelativePosition {
    /// Zero position: (0,0) in Cartesian coordinates and zero range in polar coordinates.
    static var zero: RelativePosition {
        return RelativePosition(cartesianVector: .zero)
    }
}
