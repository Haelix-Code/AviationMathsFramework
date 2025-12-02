import Foundation

/// A bearing in aviation convention (0° = North, clockwise positive, always 0..<360).
@propertyWrapper
public struct Bearing: Hashable, Codable, Sendable {
    private var _degrees: Double

    public var wrappedValue: Double {
        get { _degrees }
        set { _degrees = Self.normalize(newValue) }
    }

    public var projectedValue: Measurement<UnitAngle> {
        Measurement(value: _degrees, unit: .degrees)
    }

    public init(wrappedValue: Double) {
        self._degrees = Self.normalize(wrappedValue)
    }

    public init(degrees: Double) {
        self._degrees = Self.normalize(degrees)
    }

    public init(_ measurement: Measurement<UnitAngle>) {
        self._degrees = Self.normalize(measurement.converted(to: .degrees).value)
    }

    private static func normalize(_ degrees: Double) -> Double {
        var result = degrees.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }

    /// Reciprocal bearing (180° opposite)
    public var reciprocal: Bearing {
        Bearing(degrees: _degrees + 180)
    }

    /// Bearings perpendicular to this one
    public var perpendiculars: (left: Bearing, right: Bearing) {
        (Bearing(degrees: _degrees - 90), Bearing(degrees: _degrees + 90))
    }

    /// Shortest angular difference to another bearing (-180 to +180)
    public func difference(to other: Bearing) -> Double {
        var diff = other._degrees - _degrees
        if diff > 180 { diff -= 360 }
        if diff < -180 { diff += 360 }
        return diff
    }
}

extension Bearing: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(degrees: value)
    }
}

extension Bearing: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(degrees: Double(value))
    }
}

extension Bearing: CustomStringConvertible {
    public var description: String {
        String(format: "%03.0f°", _degrees)
    }
}
