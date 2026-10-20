import Foundation

public protocol Vector<UnitType>: Hashable, Sendable {
    associatedtype UnitType: Dimension

    var magnitude: Measurement<UnitType> { get }
    var bearing: Measurement<UnitAngle> { get }
    var x: Measurement<UnitType> { get }
    var y: Measurement<UnitType> { get }

    init(bearing: Measurement<UnitAngle>, magnitude: Measurement<UnitType>)
    init(x: Measurement<UnitType>, y: Measurement<UnitType>)

    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Double) -> Self
    static func / (lhs: Self, rhs: Double) -> Self
    static prefix func - (vector: Self) -> Self
}

extension Vector {
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(
            x: Measurement(value: lhs.x.value + rhs.x.converted(to: lhs.x.unit).value, unit: lhs.x.unit),
            y: Measurement(value: lhs.y.value + rhs.y.converted(to: lhs.y.unit).value, unit: lhs.y.unit)
        )
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(
            x: Measurement(value: lhs.x.value - rhs.x.converted(to: lhs.x.unit).value, unit: lhs.x.unit),
            y: Measurement(value: lhs.y.value - rhs.y.converted(to: lhs.y.unit).value, unit: lhs.y.unit)
        )
    }

    public static prefix func - (vector: Self) -> Self {
        Self(
            x: Measurement(value: -vector.x.value, unit: vector.x.unit),
            y: Measurement(value: -vector.y.value, unit: vector.y.unit)
        )
    }

    public static func * (lhs: Self, rhs: Double) -> Self {
        Self(
            x: Measurement(value: lhs.x.value * rhs, unit: lhs.x.unit),
            y: Measurement(value: lhs.y.value * rhs, unit: lhs.y.unit)
        )
    }

    public static func * (lhs: Double, rhs: Self) -> Self {
        rhs * lhs
    }

    public static func / (lhs: Self, rhs: Double) -> Self {
        precondition(rhs != 0, "Division by zero")
        return Self(
            x: Measurement(value: lhs.x.value / rhs, unit: lhs.x.unit),
            y: Measurement(value: lhs.y.value / rhs, unit: lhs.y.unit)
        )
    }
}

extension Vector {
    public static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }
    public static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }
    public static func *= (lhs: inout Self, rhs: Double) { lhs = lhs * rhs }
    public static func /= (lhs: inout Self, rhs: Double) { lhs = lhs / rhs }
}

extension Vector {
    public var isZero: Bool {
        magnitude.value == 0
    }

    /// Dot product, in `x.unit` squared.
    public func dot(_ other: Self) -> Double {
        x.value * other.x.converted(to: x.unit).value +
        y.converted(to: x.unit).value * other.y.converted(to: x.unit).value
    }

    public func angle(to other: Self) -> Measurement<UnitAngle> {
        let dotProduct = dot(other)
        let magnitudeProduct = magnitude.converted(to: x.unit).value * other.magnitude.converted(to: x.unit).value
        guard magnitudeProduct > 0 else {
            return Measurement(value: 0, unit: .radians)
        }

        let ratio = max(-1, min(1, dotProduct / magnitudeProduct))
        return Measurement(value: acos(ratio), unit: .radians)
    }
}
