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

    public init(vectors: [CartesianVector<UnitType>]) {
        self.x = Measurement(
            value: vectors.map { $0.x.value }.reduce(0, +),
            unit: vectors.first?.x.unit ?? UnitType.baseUnit()
        )
        self.y = Measurement(
            value: vectors.map { $0.y.value }.reduce(0, +),
            unit: vectors.first?.y.unit ?? UnitType.baseUnit()
        )
    }
}

extension CartesianVector {
    /// Convert to polar using aviation convention
    /// Returns bearing (0° = North, clockwise) and magnitude
    public var asPolar: PolarVector<UnitType> {
        PolarVector(bearing: bearing, magnitude: magnitude)
    }
    
    public var magnitude: Measurement<UnitType> {
        let xVal = x.value
        let yVal = y.value
        let mag = sqrt(xVal * xVal + yVal * yVal)
        return Measurement(value: mag, unit: x.unit)
    }
    
    /// Bearing in aviation convention (0° = North, clockwise positive)
    public var bearing: Measurement<UnitAngle> {
        let xVal = x.value
        let yVal = y.value
        // atan2(x, y) for aviation - note reversed from math convention
        let radians = atan2(xVal, yVal)
        return Measurement(value: radians, unit: .radians).normalized
    }

    /// Angle between this vector and another (always positive, 0-180°)
    public func angle(between other: CartesianVector<UnitType>) -> Measurement<UnitAngle> {
        let d = dot(other).value
        let m1 = magnitude.value
        let m2 = other.magnitude.value
        guard m1 > 0, m2 > 0 else {
            return Measurement(value: 0, unit: .radians)
        }
        let ratio = max(-1, min(1, d / (m1 * m2)))
        return Measurement(value: acos(ratio), unit: .radians)
    }
}

public typealias LengthCartesianVector = CartesianVector<UnitLength>
public typealias SpeedCartesianVector = CartesianVector<UnitSpeed>
