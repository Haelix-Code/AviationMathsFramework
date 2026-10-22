import Foundation

// MARK: - Level Comparison

// `==` and `hash(into:)` are synthesized: they compare the stored value, reference and
// context, never convert, and so can't trap. These compare the physical level (AMSL).

extension Altitude {
    /// Whether both altitudes are at the same level, compared as AMSL within `tolerance`.
    /// - Throws: `AltitudeConversionError` if either altitude can't be converted to AMSL.
    public func isSameLevel(as other: Altitude, tolerance: Measurement<UnitLength>) throws -> Bool {
        let difference = try value(in: .amsl).meters - other.value(in: .amsl).meters
        return abs(difference) <= tolerance.meters
    }

    /// Whether this altitude is below `other`, compared as AMSL.
    /// - Throws: `AltitudeConversionError` if either altitude can't be converted to AMSL.
    public func isBelow(_ other: Altitude) throws -> Bool {
        try value(in: .amsl).meters < other.value(in: .amsl).meters
    }
}
