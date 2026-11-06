import Foundation

public extension Altitude {
    /// - Throws: `AltitudeArithmeticError.mismatchedContext`, or `.conversion` if either altitude
    ///   can't be converted to `ref`.
    func midpoint(to other: Altitude, in ref: VerticalReference) throws(AltitudeArithmeticError) -> Altitude {
        try requireSameContext(as: other)

        let a = try self.meters(in: ref)
        let b = try other.meters(in: ref)
        let mid = Measurement<UnitLength>(value: (a + b) / 2.0, unit: .meters)

        return Altitude(value: mid, reference: ref, context: self.context)
    }

    /// - Throws: `AltitudeArithmeticError.mismatchedContext`, or `.conversion` if either altitude
    ///   can't be converted to `ref`.
    func interpolated(
        to other: Altitude,
        fraction t: Double,
        in ref: VerticalReference
    ) throws(AltitudeArithmeticError) -> Altitude {
        try requireSameContext(as: other)

        let u = max(0.0, min(1.0, t))

        let a = try self.meters(in: ref)
        let b = try other.meters(in: ref)
        let v = a + (b - a) * u
        let m = Measurement<UnitLength>(value: v, unit: .meters)

        return Altitude(value: m, reference: ref, context: self.context)
    }

    private func requireSameContext(as other: Altitude) throws(AltitudeArithmeticError) {
        guard self.context == other.context else {
            throw .mismatchedContext
        }
    }

    private func meters(in ref: VerticalReference) throws(AltitudeArithmeticError) -> Double {
        do {
            return try value(in: ref).converted(to: .meters).value
        } catch {
            throw .conversion(error)
        }
    }
}

public enum AltitudeArithmeticError: Error, Hashable, Sendable, LocalizedError {
    case mismatchedContext
    /// An altitude couldn't be converted to the reference the arithmetic is done in.
    case conversion(AltitudeConversionError)

    public var errorDescription: String? {
        switch self {
        case .mismatchedContext:
            return "Altitudes with different contexts can't be combined"
        case .conversion(let error):
            return error.errorDescription
        }
    }
}
