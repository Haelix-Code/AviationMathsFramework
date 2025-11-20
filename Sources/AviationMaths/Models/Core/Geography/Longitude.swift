import Foundation

public struct Longitude: AngularCoordinate {
    public typealias DirectionType = LongitudeDirection

    public static let validRange: ClosedRange<Double> = -180.0...180.0

    public let decimalDegrees: Double

    public var direction: LongitudeDirection {
        LongitudeDirection(decimalDegrees: decimalDegrees)
    }

    public init(decimalDegrees: Double) {
        precondition(
            Self.validRange.contains(decimalDegrees),
            "Longitude must be between -180° and +180°, got \(decimalDegrees)°"
        )
        self.decimalDegrees = decimalDegrees
    }

    public init(degrees: Double, direction: LongitudeDirection) {
        let value = abs(degrees) * direction.sign
        self.init(decimalDegrees: value)
    }

    public init(_ angle: Measurement<UnitAngle>) {
        self.init(decimalDegrees: angle.converted(to: .degrees).value)
    }

    public init(dms: DegreesMinutesSeconds, direction: LongitudeDirection) {
        let decimal = dms.asDecimalDegrees
        self.init(degrees: decimal, direction: direction)
    }

    public init(ddm: DegreesDecimalMinutes, direction: LongitudeDirection) {
        let decimal = ddm.asDecimalDegrees
        self.init(degrees: decimal, direction: direction)
    }

    public init(degrees: Int, minutes: Int, seconds: Double, direction: LongitudeDirection) {
        let dms = DegreesMinutesSeconds(degrees: degrees, minutes: minutes, seconds: seconds)
        self.init(dms: dms, direction: direction)
    }

    public init(degrees: Int, minutes: Double, direction: LongitudeDirection) {
        let ddm = DegreesDecimalMinutes(degrees: degrees, minutes: minutes)
        self.init(ddm: ddm, direction: direction)
    }

}
