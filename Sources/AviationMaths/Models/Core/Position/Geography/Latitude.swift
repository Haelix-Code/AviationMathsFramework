import Foundation

public struct Latitude: AngularCoordinate {
    public typealias DirectionType = LatitudeDirection

    public static let validRange: ClosedRange<Double> = -90.0...90.0

    public let decimalDegrees: Double

    public var direction: LatitudeDirection {
        LatitudeDirection(decimalDegrees: decimalDegrees)
    }

    /// - Throws: `CoordinateError.latitudeOutOfRange` unless `decimalDegrees` is within ±90° (so also for NaN).
    public init(decimalDegrees: Double) throws(CoordinateError) {
        guard Self.validRange.contains(decimalDegrees) else {
            throw .latitudeOutOfRange(decimalDegrees)
        }
        self.decimalDegrees = decimalDegrees
    }

    public init(degrees: Double, direction: LatitudeDirection) throws(CoordinateError) {
        let value = abs(degrees) * direction.sign
        try self.init(decimalDegrees: value)
    }

    public init(measurement: Measurement<UnitAngle>) throws(CoordinateError) {
        try self.init(decimalDegrees: measurement.converted(to: .degrees).value)
    }

    public init(dms: DegreesMinutesSeconds, direction: LatitudeDirection) throws(CoordinateError) {
        let decimal = dms.asDecimalDegrees
        try self.init(degrees: decimal, direction: direction)
    }

    public init(ddm: DegreesDecimalMinutes, direction: LatitudeDirection) throws(CoordinateError) {
        let decimal = ddm.asDecimalDegrees
        try self.init(degrees: decimal, direction: direction)
    }

    public init(degrees: Int, minutes: Int, seconds: Double, direction: LatitudeDirection) throws(CoordinateError) {
        let dms = DegreesMinutesSeconds(degrees: degrees, minutes: minutes, seconds: seconds)
        try self.init(dms: dms, direction: direction)
    }

    public init(degrees: Int, minutes: Double, direction: LatitudeDirection) throws(CoordinateError) {
        let ddm = DegreesDecimalMinutes(degrees: degrees, minutes: minutes)
        try self.init(ddm: ddm, direction: direction)
    }
}
