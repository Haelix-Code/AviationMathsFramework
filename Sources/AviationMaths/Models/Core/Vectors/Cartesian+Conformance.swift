extension CartesianVector: Equatable {
    public static func == (lhs: CartesianVector, rhs: CartesianVector) -> Bool {
        lhs.x.converted(to: UnitType.baseUnit()).value == rhs.x.converted(to: UnitType.baseUnit()).value &&
        lhs.y.converted(to: UnitType.baseUnit()).value == rhs.y.converted(to: UnitType.baseUnit()).value
    }
}

extension CartesianVector: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x.converted(to: UnitType.baseUnit()).value)
        hasher.combine(y.converted(to: UnitType.baseUnit()).value)
    }
}
