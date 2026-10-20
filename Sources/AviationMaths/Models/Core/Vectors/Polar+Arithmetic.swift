import Foundation

public extension PolarVector {
    func adding(_ other: PolarVector) -> PolarVector {
        let sum = self.asCartesianVector + other.asCartesianVector
        return sum.asPolar
    }

    func subtracting(_ other: PolarVector) -> PolarVector {
        let diff = self.asCartesianVector - other.asCartesianVector
        return diff.asPolar
    }

    /// Rotate bearing by given angle (positive = clockwise)
    func rotated(by angle: Measurement<UnitAngle>) -> PolarVector {
        let newBearing = Measurement<UnitAngle>(
            value: self.bearing.converted(to: .degrees).value +
                   angle.converted(to: .degrees).value,
            unit: .degrees
        )
        return PolarVector(bearing: newBearing, magnitude: magnitude)
    }

    var normalized: PolarVector {
        PolarVector(bearing: bearing, magnitude: Measurement(value: 1.0, unit: magnitude.unit))
    }

    func dotProduct(_ other: PolarVector) -> Measurement<UnitType> {
        let m1 = magnitude.value
        let m2 = other.magnitude.value
        let bearingDiff = (bearing.converted(to: .radians).value -
                          other.bearing.converted(to: .radians).value)
        return Measurement(value: m1 * m2 * cos(bearingDiff), unit: magnitude.unit)
    }

    func angleBetween(_ other: PolarVector) -> Measurement<UnitAngle> {
        let dot = dotProduct(other).value
        let m1 = magnitude.value
        let m2 = other.magnitude.value
        guard m1 > 0, m2 > 0 else {
            // Matches Vector.angle(to:)'s convention for a zero vector, rather than NaN.
            return Measurement(value: 0, unit: .radians)
        }
        let ratio = max(-1, min(1, dot / (m1 * m2)))
        return Measurement(value: acos(ratio), unit: .radians)
    }
}
