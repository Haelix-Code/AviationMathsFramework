import Foundation

/// A Cartesian vector where:
/// - x = East (positive) / West (negative)
/// - y = North (positive) / South (negative)
public struct CartesianVector<UnitType: Dimension> {
    public let x: Measurement<UnitType> // East-West component
    public let y: Measurement<UnitType> // North-South component

    public init(x: Measurement<UnitType>, y: Measurement<UnitType>) {
        self.x = x
        self.y = y
    }

    /// Sum of `vectors`, in the first vector's `x` unit.
    public static func sum(_ vectors: [CartesianVector<UnitType>]) -> CartesianVector<UnitType> {
        let unit = vectors.first?.x.unit ?? UnitType.baseUnit()
        return CartesianVector(
            x: Measurement(
            value: vectors.map { $0.x.converted(to: unit).value }.reduce(0, +),
            unit: unit
        ),
            y: Measurement(
            value: vectors.map { $0.y.converted(to: unit).value }.reduce(0, +),
            unit: unit
        )
        )
    }
}

extension CartesianVector: Vector {
    public init(bearing: Measurement<UnitAngle>, magnitude: Measurement<UnitType>) {
        let rad = bearing.converted(to: .radians).value
        let mag = magnitude.value
        self.init(
            x: Measurement(value: mag * sin(rad), unit: magnitude.unit),
            y: Measurement(value: mag * cos(rad), unit: magnitude.unit)
        )
    }

    public var magnitude: Measurement<UnitType> {
        let xVal = x.value
        let yVal = y.converted(to: x.unit).value
        let mag = sqrt(xVal * xVal + yVal * yVal)
        return Measurement(value: mag, unit: x.unit)
    }

    /// Bearing in aviation convention (0° = North, clockwise positive)
    public var bearing: Measurement<UnitAngle> {
        let xVal = x.value
        let yVal = y.converted(to: x.unit).value
        // atan2(x, y) for aviation - note reversed from math convention
        let radians = atan2(xVal, yVal)
        return Measurement(value: radians, unit: .radians).normalized
    }

    /// Angle between this vector and another (always positive, 0-180°)
    public func angle(between other: CartesianVector<UnitType>) -> Measurement<UnitAngle> {
        let magnitudeProduct = magnitude.value * other.magnitude.converted(to: magnitude.unit).value
        guard magnitudeProduct > 0 else {
            // Matches Vector.angle(to:)'s convention for a zero vector, rather than NaN.
            return Measurement(value: 0, unit: .radians)
        }
        let ratio = max(-1, min(1, dot(other) / magnitudeProduct))
        return Measurement(value: acos(ratio), unit: .radians)
    }
    /// Returns bearing (0° = North, clockwise) and magnitude
    public var asPolar: PolarVector<UnitType> {
        PolarVector(bearing: bearing, magnitude: magnitude)
    }
}

public extension CartesianVector {
    /// Zero vector: (0, 0) in Cartesian coordinates.
    static var zero: CartesianVector<UnitType> {
        return CartesianVector(x: Measurement(value: 0, unit: UnitType.baseUnit()), y: Measurement(value: 0, unit: UnitType.baseUnit()))
    }
}

public typealias LengthCartesianVector = CartesianVector<UnitLength>
public typealias SpeedCartesianVector = CartesianVector<UnitSpeed>
