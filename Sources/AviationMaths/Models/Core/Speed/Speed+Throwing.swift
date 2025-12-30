import Foundation

extension Speed {
    // MARK: - Throwing Conversion Methods

    /// Convert to CAS, throwing if context is insufficient
    public func asCAS() throws -> Measurement<UnitSpeed> {
        guard reference != .calibratedAirspeed else { return value }
        return try convertToCAS()
    }

    /// Convert to EAS, throwing if context is insufficient
    public func asEAS() throws -> Measurement<UnitSpeed> {
        guard reference != .equivalentAirspeed else { return value }
        return try convertToEAS()
    }

    /// Convert to TAS, throwing if context is insufficient
    public func asTAS() throws -> Measurement<UnitSpeed> {
        guard reference != .trueAirspeed else { return value }
        return try convertToTAS()
    }

    /// Convert to Mach, throwing if context is insufficient
    public func asMach() throws -> Double {
        guard reference != .machNumber else { return machValue! }
        return try convertToMach()
    }

}
