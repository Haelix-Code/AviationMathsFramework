import Foundation

extension CartesianVector {
    func dot(_ other: CartesianVector<UnitType>) -> Measurement<UnitType> {
        let v = x.value * other.x.converted(to: x.unit).value +
                y.converted(to: x.unit).value * other.y.converted(to: x.unit).value
        return Measurement(value: v, unit: x.unit)
    }
}

extension CartesianVector {
    public static func += (lhs: inout CartesianVector, rhs: CartesianVector) {
        lhs = lhs + rhs
    }

    public static func -= (lhs: inout CartesianVector, rhs: CartesianVector) {
        lhs = lhs - rhs
    }

    public static func *= (lhs: inout CartesianVector, rhs: Double) {
        lhs = lhs * rhs
    }

    public static func /= (lhs: inout CartesianVector, rhs: Double) {
        lhs = lhs / rhs
    }
}
