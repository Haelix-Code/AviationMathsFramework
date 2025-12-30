import Foundation

extension Speed {

    public var canConvertToCAS: Bool {
        switch reference {
        case .calibratedAirspeed:
            return true
        case .equivalentAirspeed, .trueAirspeed:
            return context.relativePressure != nil
        case .machNumber:
            return context.speedOfSound != nil && context.relativePressure != nil
        }
    }

    public var canConvertToEAS: Bool {
        switch reference {
        case .equivalentAirspeed:
            return true
        case .calibratedAirspeed:
            return context.relativePressure != nil
        case .trueAirspeed:
            return context.density != nil
        case .machNumber:
            return context.speedOfSound != nil && context.density != nil
        }
    }

    public var canConvertToTAS: Bool {
        switch reference {
        case .trueAirspeed:
            return true
        case .calibratedAirspeed, .equivalentAirspeed:
            return context.density != nil
        case .machNumber:
            return context.speedOfSound != nil
        }
    }

    public var canConvertToMach: Bool {
        context.speedOfSound != nil
    }

    public func canConvert(to targetReference: SpeedReference) -> Bool {
        switch targetReference {
        case .calibratedAirspeed: return canConvertToCAS
        case .equivalentAirspeed: return canConvertToEAS
        case .trueAirspeed: return canConvertToTAS
        case .machNumber: return canConvertToMach
        }
    }

    // MARK: - Safe Conversions (Return Optional)

    // CAS if conversion is possible, nil otherwise
    public var casIfPossible: Measurement<UnitSpeed>? {
        reference == .calibratedAirspeed ? value : try? convertToCAS()
    }

    /// EAS if conversion is possible, nil otherwise
    public var easIfPossible: Measurement<UnitSpeed>? {
        reference == .equivalentAirspeed ? value : try? convertToEAS()
    }

    /// TAS if conversion is possible, nil otherwise
    public var tasIfPossible: Measurement<UnitSpeed>? {
        reference == .trueAirspeed ? value : try? convertToTAS()
    }

    /// Mach number if conversion is possible, nil otherwise
    public var machIfPossible: Double? {
        reference == .machNumber ? machValue : try? convertToMach()
    }
}
