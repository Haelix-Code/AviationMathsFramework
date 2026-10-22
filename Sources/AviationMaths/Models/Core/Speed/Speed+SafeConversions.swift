import Foundation

extension Speed {

    // Each mirrors the route the matching `convertTo…` takes, so they can't disagree.

    public var canConvertToCAS: Bool {
        switch reference {
        case .calibratedAirspeed:
            return true
        case .equivalentAirspeed:
            return (try? context.relativePressure) != nil
        case .trueAirspeed:
            return (try? context.density) != nil && (try? context.relativePressure) != nil
        case .machNumber:
            return (try? context.speedOfSound) != nil
                && (try? context.density) != nil
                && (try? context.relativePressure) != nil
        }
    }

    public var canConvertToEAS: Bool {
        switch reference {
        case .equivalentAirspeed:
            return true
        case .calibratedAirspeed:
            return (try? context.relativePressure) != nil
        case .trueAirspeed:
            return (try? context.density) != nil
        case .machNumber:
            return (try? context.speedOfSound) != nil && (try? context.density) != nil
        }
    }

    public var canConvertToTAS: Bool {
        switch reference {
        case .trueAirspeed:
            return true
        case .calibratedAirspeed:
            return (try? context.density) != nil && (try? context.relativePressure) != nil
        case .equivalentAirspeed:
            return (try? context.density) != nil
        case .machNumber:
            return (try? context.speedOfSound) != nil
        }
    }

    public var canConvertToMach: Bool {
        switch reference {
        case .machNumber:
            return true
        case .calibratedAirspeed:
            return (try? context.relativePressure) != nil
        case .equivalentAirspeed:
            return (try? context.density) != nil && (try? context.speedOfSound) != nil
        case .trueAirspeed:
            return (try? context.speedOfSound) != nil
        }
    }

    public func canConvert(to targetReference: SpeedReference) -> Bool {
        switch targetReference {
        case .calibratedAirspeed: return canConvertToCAS
        case .equivalentAirspeed: return canConvertToEAS
        case .trueAirspeed: return canConvertToTAS
        case .machNumber: return canConvertToMach
        }
    }
}
