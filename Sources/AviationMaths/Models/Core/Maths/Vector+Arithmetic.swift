extension Vector2D {
    public static func + (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
        Vector2D(vectors: [lhs, rhs])
    }

    public static func - (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
        Vector2D(
            x: .init(meters: lhs.x.meters - rhs.x.meters),
            y: .init(meters: lhs.y.meters - rhs.y.meters)
        )
    }

    public static prefix func - (vector: Vector2D) -> Vector2D {
        Vector2D(
            x: .init(meters: -vector.x.meters),
            y: .init(meters: -vector.y.meters)
        )
    }

    public static func * (lhs: Vector2D, rhs: Double) -> Vector2D {
        Vector2D(
            x: .init(meters: lhs.x.meters * rhs),
            y: .init(meters: lhs.y.meters * rhs)
        )
    }

    public static func * (lhs: Double, rhs: Vector2D) -> Vector2D {
        rhs * lhs
    }

    public static func / (lhs: Vector2D, rhs: Double) -> Vector2D {
        precondition(rhs != 0)
        return Vector2D(
            x: .init(meters: lhs.x.meters / rhs),
            y: .init(meters: lhs.y.meters / rhs)
        )
    }

}

extension Vector2D {
    public static func += (lhs: inout Vector2D, rhs: Vector2D) {
        lhs = lhs + rhs
    }

    public static func -= (lhs: inout Vector2D, rhs: Vector2D) {
        lhs = lhs - rhs
    }

    public static func *= (lhs: inout Vector2D, rhs: Double) {
        lhs = lhs * rhs
    }

    public static func /= (lhs: inout Vector2D, rhs: Double) {
        lhs = lhs / rhs
    }
}
