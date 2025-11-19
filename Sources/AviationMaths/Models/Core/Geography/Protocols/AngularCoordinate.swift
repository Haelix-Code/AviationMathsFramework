import Foundation

public protocol AngularCoordinate: Equatable, Hashable, Codable, Sendable {
    associatedtype DirectionType: Equatable, Hashable, Codable, Sendable

    var decimalDegrees: Double { get }

    static var validRange: ClosedRange<Double> { get }

    init(decimalDegrees: Double)

    var direction: DirectionType { get }
}

extension AngularCoordinate {
    public var unsignedDecimalDegrees: Double {
        abs(decimalDegrees)
    }

    public var degreesMinutesSeconds: DegreesMinutesSeconds {
        DegreesMinutesSeconds(decimalDegrees: decimalDegrees)
    }

    public var degreesDecimalMinutes: DegreesDecimalMinutes {
        DegreesDecimalMinutes(decimalDegrees: decimalDegrees)
    }

    public var isValid: Bool {
        Self.validRange.contains(decimalDegrees)
    }

    public var asMEasurement: Measurement<UnitAngle> {
        Measurement(value: decimalDegrees, unit: .degrees)
    }
}

// Comparable
extension AngularCoordinate {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.decimalDegrees < rhs.decimalDegrees
    }
}

extension AngularCoordinate {
    public static func isValid(decimalDegrees value: Double) -> Bool {
        validRange.contains(value)
    }
}
