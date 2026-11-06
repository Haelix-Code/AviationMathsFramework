import Foundation

public struct Longitude: AngularCoordinate {
    public typealias DirectionType = LongitudeDirection

    public static let validRange: ClosedRange<Double> = -180.0...180.0

    public let decimalDegrees: Double

    public var direction: LongitudeDirection {
        LongitudeDirection(decimalDegrees: decimalDegrees)
    }

    /// - Throws: `CoordinateError.longitudeOutOfRange` unless `decimalDegrees` is within ±180° (so also for NaN).
    public init(decimalDegrees: Double) throws(CoordinateError) {
        guard Self.validRange.contains(decimalDegrees) else {
            throw .longitudeOutOfRange(decimalDegrees)
        }
        self.decimalDegrees = decimalDegrees
    }

    public init(degrees: Double, direction: LongitudeDirection) throws(CoordinateError) {
        let value = abs(degrees) * direction.sign
        try self.init(decimalDegrees: value)
    }

    public init(measurement: Measurement<UnitAngle>) throws(CoordinateError) {
        try self.init(decimalDegrees: measurement.converted(to: .degrees).value)
    }

    public init(dms: DegreesMinutesSeconds, direction: LongitudeDirection) throws(CoordinateError) {
        let decimal = dms.asDecimalDegrees
        try self.init(degrees: decimal, direction: direction)
    }

    public init(ddm: DegreesDecimalMinutes, direction: LongitudeDirection) throws(CoordinateError) {
        let decimal = ddm.asDecimalDegrees
        try self.init(degrees: decimal, direction: direction)
    }

    public init(degrees: Int, minutes: Int, seconds: Double, direction: LongitudeDirection) throws(CoordinateError) {
        let dms = DegreesMinutesSeconds(degrees: degrees, minutes: minutes, seconds: seconds)
        try self.init(dms: dms, direction: direction)
    }

    public init(degrees: Int, minutes: Double, direction: LongitudeDirection) throws(CoordinateError) {
        let ddm = DegreesDecimalMinutes(degrees: degrees, minutes: minutes)
        try self.init(ddm: ddm, direction: direction)
    }
}
