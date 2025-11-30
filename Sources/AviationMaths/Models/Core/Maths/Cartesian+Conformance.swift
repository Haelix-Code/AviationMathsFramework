extension CartesianVector: Equatable {
    public static func == (lhs: CartesianVector, rhs: CartesianVector) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension CartesianVector: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
