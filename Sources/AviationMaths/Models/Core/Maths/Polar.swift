import Foundation

/// A polar vector using aviation convention:
/// - 0° = North (+y axis)
/// - 90° = East (+x axis)
/// - Angles increase clockwise
public struct PolarVector<UnitType: Dimension>: Equatable {
    /// Bearing in aviation convention (0° = North, clockwise positive)
    public let bearing: Measurement<UnitAngle>
    public let magnitude: Measurement<UnitType>

    public init(bearing: Measurement<UnitAngle>, magnitude: Measurement<UnitType>) {
        self.bearing = bearing.normalized
        self.magnitude = magnitude
    }
    
    /// Convert to Cartesian using aviation convention
    /// x = East (+), y = North (+)
    public var asCartesianVector: CartesianVector<UnitType> {
        let bearingRad = bearing.converted(to: .radians).value
        let mag = magnitude.value
        return CartesianVector(
            x: Measurement(value: mag * sin(bearingRad), unit: magnitude.unit),
            y: Measurement(value: mag * cos(bearingRad), unit: magnitude.unit)
        )
    }
}

public typealias LengthPolar = PolarVector<UnitLength>
public typealias SpeedPolar = PolarVector<UnitSpeed>
