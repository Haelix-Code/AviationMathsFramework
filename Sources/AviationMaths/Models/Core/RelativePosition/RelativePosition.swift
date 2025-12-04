import Foundation

public struct RelativePosition {
    public let cartesianVector: LengthCartesianVector
    public var polarCoordinate: LengthPolar

    public init(bearing: Measurement<UnitAngle>, range: Measurement<UnitLength>) {
        self.polarCoordinate = PolarVector(bearing: bearing, magnitude: range)
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

    public var perpendiculars: [Measurement<UnitAngle>] {
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
