import Foundation

extension RelativePosition {
    public static func + (lhs: RelativePosition, rhs: RelativePosition) -> RelativePosition {
        let resultVector = lhs.cartesianVector + rhs.cartesianVector
        return RelativePosition(cartesianVector: resultVector)
    }

    public static func - (lhs: RelativePosition, rhs: RelativePosition) -> RelativePosition {
        let resultVector = lhs.cartesianVector - rhs.cartesianVector
        return RelativePosition(cartesianVector: resultVector)
    }

    /// Negates a relative position.
    public static prefix func - (position: RelativePosition) -> RelativePosition {
        RelativePosition(cartesianVector: -position.cartesianVector)
    }
}

extension RelativePosition {
    public static func * (lhs: RelativePosition, rhs: Double) -> RelativePosition {
        let resultVector = lhs.cartesianVector * rhs
        return RelativePosition(cartesianVector: resultVector)
    }

    public static func * (lhs: Double, rhs: RelativePosition) -> RelativePosition {
        rhs * lhs
    }

    public static func / (lhs: RelativePosition, rhs: Double) -> RelativePosition {
        precondition(rhs != 0, "Cannot divide by zero")
        let resultVector = lhs.cartesianVector / rhs
        return RelativePosition(cartesianVector: resultVector)
    }
}

extension RelativePosition {
    public static func += (lhs: inout RelativePosition, rhs: RelativePosition) {
        lhs = lhs + rhs
    }

    public static func -= (lhs: inout RelativePosition, rhs: RelativePosition) {
        lhs = lhs - rhs
    }

    public static func *= (lhs: inout RelativePosition, rhs: Double) {
        lhs = lhs * rhs
    }

    public static func /= (lhs: inout RelativePosition, rhs: Double) {
        lhs = lhs / rhs
    }
}
