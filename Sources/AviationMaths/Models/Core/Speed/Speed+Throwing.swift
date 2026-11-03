import Foundation

extension Speed {
    // MARK: - Throwing Conversion Methods

    /// This speed in another reference, in the same context. Use `try?` for an optional result.
    /// - Throws: `ContextCalculationError` if the context lacks the data the conversion needs.
    public func converted(to newReference: SpeedReference) throws -> Speed {
        switch newReference {
        case .calibratedAirspeed:
            return Speed(value: try convertToCAS(), reference: .calibratedAirspeed, context: context)
        case .equivalentAirspeed:
            return Speed(value: try convertToEAS(), reference: .equivalentAirspeed, context: context)
        case .trueAirspeed:
            return Speed(value: try convertToTAS(), reference: .trueAirspeed, context: context)
        case .machNumber:
            return Speed(mach: try convertToMach(), context: context)
        }
    }

    /// Convert to CAS, throwing if context is insufficient
    @available(*, deprecated, message: "Use `try converted(to: .calibratedAirspeed).value`.")
    public func asCAS() throws -> Measurement<UnitSpeed> {
        guard reference != .calibratedAirspeed else { return value }
        return try convertToCAS()
    }

    /// Convert to EAS, throwing if context is insufficient
    @available(*, deprecated, message: "Use `try converted(to: .equivalentAirspeed).value`.")
    public func asEAS() throws -> Measurement<UnitSpeed> {
        guard reference != .equivalentAirspeed else { return value }
        return try convertToEAS()
    }

    /// Convert to TAS, throwing if context is insufficient
    @available(*, deprecated, message: "Use `try converted(to: .trueAirspeed).value`.")
    public func asTAS() throws -> Measurement<UnitSpeed> {
        guard reference != .trueAirspeed else { return value }
        return try convertToTAS()
    }

    /// Convert to Mach, throwing if context is insufficient
    @available(*, deprecated, message: "Use `try converted(to: .machNumber).mach`.")
    public func asMach() throws -> Double {
        guard reference != .machNumber else { return machValue! }
        return try convertToMach()
    }

    @available(*, deprecated, renamed: "converted(to:)")
    public func convertedThrowing(to newReference: SpeedReference) throws -> Speed {
        try converted(to: newReference)
    }

}
