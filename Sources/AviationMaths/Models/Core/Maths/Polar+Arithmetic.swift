import Foundation

public extension PolarVector where Magnitude == Measurement<UnitLength> {
    func adding(_ other: PolarVector) -> PolarVector {
        let v1 = self.vector2D
        let v2 = other.vector2D

        let sum = Vector2D(
            x: .init(meters: v1.x.meters + v2.x.meters),
            y: .init(meters: v1.y.meters + v2.y.meters)
        )

        return sum.polarCoordinate
    }

    func subtracting(_ other: PolarVector) -> PolarVector {
        let v1 = self.vector2D
        let v2 = other.vector2D

        let diff = Vector2D(
            x: .init(meters: v1.x.meters - v2.x.meters),
            y: .init(meters: v1.y.meters - v2.y.meters)
        )

        return diff.polarCoordinate
    }

    func rotated(by angle: Measurement<UnitAngle>) -> PolarVector {
        let newAngle = Measurement<UnitAngle>(
            value: self.angle.radians + angle.radians,
            unit: .radians
        )
        return PolarVector(angle: newAngle, magnitude: magnitude)
    }

    var normalized: PolarVector {
        PolarVector(
            angle: self.angle,
            magnitude: Measurement<UnitLength>(meters: 1.0)
        )
    }

    func dotProduct(_ other: PolarVector) -> Measurement<UnitLength> {
        let m1 = self.magnitude.meters
        let m2 = other.magnitude.meters
        let angleDiff = self.angle.radians - other.angle.radians

        return Measurement(value: m1 * m2 * cos(angleDiff), unit: .meters)
    }

    func angleBetween(_ other: PolarVector) -> Measurement<UnitAngle> {
        let dot = self.dotProduct(other).value
        let m1 = self.magnitude.meters
        let m2 = other.magnitude.meters

        guard m1 > 0, m2 > 0 else {
            return Measurement(value: .nan, unit: .radians)
        }

        let ratio = max(-1.0, min(1.0, dot / (m1 * m2)))
        return Measurement(value: acos(ratio), unit: .radians)
    }
}
