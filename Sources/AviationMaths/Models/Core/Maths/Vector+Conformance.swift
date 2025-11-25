extension Vector2D: Equatable {
    public static func == (lhs: Vector2D, rhs: Vector2D) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension Vector2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
