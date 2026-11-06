import Foundation

extension Altitude {

    // Each tries the conversion itself, so a check can't disagree with its conversion.

    public var canConvertToAGL: Bool { canConvert(to: .agl) }

    public var canConvertToAMSL: Bool { canConvert(to: .amsl) }

    public var canConvertToPressureAltitude: Bool { canConvert(to: .pressureAltitude) }

    public var canConvertToTrueAltitude: Bool { canConvert(to: .trueAltitude) }

    /// Geopotential altitude requires true altitude, which requires a temperature profile
    public var canConvertToGeopotential: Bool { canConvert(to: .geopotential) }

    /// Whether `value(in: targetReference)` succeeds with this altitude's context.
    public func canConvert(to targetReference: VerticalReference) -> Bool {
        (try? value(in: targetReference)) != nil
    }
}
