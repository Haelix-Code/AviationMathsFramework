import Foundation

extension Speed {

    // Each tries the conversion itself, so a check can't disagree with its conversion.

    public var canConvertToCAS: Bool { canConvert(to: .calibratedAirspeed) }

    public var canConvertToEAS: Bool { canConvert(to: .equivalentAirspeed) }

    public var canConvertToTAS: Bool { canConvert(to: .trueAirspeed) }

    public var canConvertToMach: Bool { canConvert(to: .machNumber) }

    /// Whether `converted(to: targetReference)` succeeds with this speed's context.
    public func canConvert(to targetReference: SpeedReference) -> Bool {
        (try? converted(to: targetReference)) != nil
    }
}
