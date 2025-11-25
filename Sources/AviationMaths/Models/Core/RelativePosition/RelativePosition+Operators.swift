import Foundation

extension RelativePosition {
    public static func + (lhs: RelativePosition, rhs: RelativePosition) -> RelativePosition {
        let resultVector = lhs.vector2D + rhs.vector2D
        return RelativePosition(vector2D: resultVector)
    }

    public static func - (lhs: RelativePosition, rhs: RelativePosition) -> RelativePosition {
        let resultVector = lhs.vector2D - rhs.vector2D
        return RelativePosition(vector2D: resultVector)
    }

    /// Negates a relative position.
    public static prefix func - (position: RelativePosition) -> RelativePosition {
        RelativePosition(vector2D: -position.vector2D)
    }
}

extension RelativePosition {

    public static func * (lhs: RelativePosition, rhs: Double) -> RelativePosition {
        let resultVector = lhs.vector2D * rhs
        return RelativePosition(vector2D: resultVector)
    }

    public static func * (lhs: Double, rhs: RelativePosition) -> RelativePosition {
        rhs * lhs
    }

    public static func / (lhs: RelativePosition, rhs: Double) -> RelativePosition {
        precondition(rhs != 0, "Cannot divide by zero")
        let resultVector = lhs.vector2D / rhs
        return RelativePosition(vector2D: resultVector)
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
