import Foundation

extension CartesianVector {
    static func + (lhs: CartesianVector, rhs: CartesianVector) -> CartesianVector {
        CartesianVector(
            x: Measurement(value: lhs.x.value + rhs.x.value, unit: lhs.x.unit),
            y: Measurement(value: lhs.y.value + rhs.y.value, unit: lhs.y.unit)
        )
    }

    static func - (lhs: CartesianVector, rhs: CartesianVector) -> CartesianVector {
        CartesianVector(
            x: Measurement(value: lhs.x.value - rhs.x.value, unit: lhs.x.unit),
            y: Measurement(value: lhs.y.value - rhs.y.value, unit: lhs.y.unit)
        )
    }

    static prefix func - (vector: CartesianVector) -> CartesianVector {
        CartesianVector(
            x: Measurement(value: -vector.x.value, unit: vector.x.unit),
            y: Measurement(value: -vector.y.value, unit: vector.y.unit)
        )
    }

    static func * (lhs: CartesianVector, rhs: Double) -> CartesianVector {
        CartesianVector(
            x: Measurement(value: lhs.x.value * rhs, unit: lhs.x.unit),
            y: Measurement(value: lhs.y.value * rhs, unit: lhs.y.unit)
        )
    }

    static func * (lhs: Double, rhs: CartesianVector) -> CartesianVector {
        rhs * lhs
    }

    static func / (lhs: CartesianVector, rhs: Double) -> CartesianVector {
        precondition(rhs != 0, "Division by zero")
        return CartesianVector(
            x: Measurement(value: lhs.x.value / rhs, unit: lhs.x.unit),
            y: Measurement(value: lhs.y.value / rhs, unit: lhs.y.unit)
        )
    }
    
    func dot(_ other: CartesianVector<UnitType>) -> Measurement<UnitType> {
        let v = x.value * other.x.value + y.value * other.y.value
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
