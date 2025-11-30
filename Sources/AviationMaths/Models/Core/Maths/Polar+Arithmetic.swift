import Foundation

public extension PolarVector {
    func adding(_ other: PolarVector) -> PolarVector {
        let sumX = self.asCartesianVector.x.value + other.asCartesianVector.x.value
        let sumY = self.asCartesianVector.y.value + other.asCartesianVector.y.value
        
        let sum = CartesianVector(
            x: Measurement(value: sumX, unit: magnitude.unit),
            y: Measurement(value: sumY, unit: magnitude.unit)
        )

        return sum.asPolar
    }

    func subtracting(_ other: PolarVector) -> PolarVector {
        let diffX = self.asCartesianVector.x.value - other.asCartesianVector.x.value
        let diffY = self.asCartesianVector.y.value - other.asCartesianVector.y.value

        let diff = CartesianVector(
            x: Measurement(value: diffX, unit: magnitude.unit),
            y: Measurement(value: diffY, unit: magnitude.unit)
        )

        return diff.asPolar
    }

    func rotated(by angle: Measurement<UnitAngle>) -> PolarVector {
       let newAngle = Measurement<UnitAngle>(
           value: self.angle.converted(to: .radians).value +
                  angle.converted(to: .radians).value,
           unit: .radians
       )

       return PolarVector(angle: newAngle, magnitude: magnitude)
    }

    var normalized: PolarVector {
        PolarVector(
            angle: angle,
            magnitude: Measurement(value: 1.0, unit: magnitude.unit)
        )
    }

    func dotProduct(_ other: PolarVector) -> Measurement<UnitType> {
        let m1 = magnitude.value
        let m2 = other.magnitude.value
        let angleDiff = angle.converted(to: .radians).value -
                        other.angle.converted(to: .radians).value

        return Measurement(value: m1 * m2 * cos(angleDiff), unit: magnitude.unit)
    }

    func angleBetween(_ other: PolarVector) -> Measurement<UnitAngle> {
        let dot = dotProduct(other).value
        let m1 = magnitude.value
        let m2 = other.magnitude.value

        guard m1 > 0, m2 > 0 else {
            return Measurement(value: .nan, unit: .radians)
        }

        let ratio = max(-1, min(1, dot / (m1 * m2)))
        return Measurement(value: acos(ratio), unit: .radians)
    }
}
