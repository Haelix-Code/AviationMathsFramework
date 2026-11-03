import Foundation

public extension Altitude {
    func midpoint(to other: Altitude, in ref: VerticalReference) throws -> Altitude {
        try requireSameContext(as: other)

        let a = try self.value(in: ref).converted(to: .meters).value
        let b = try other.value(in: ref).converted(to: .meters).value
        let mid = Measurement<UnitLength>(value: (a + b) / 2.0, unit: .meters)

        return Altitude(value: mid, reference: ref, context: self.context)
    }

    func interpolated(to other: Altitude, fraction t: Double, in ref: VerticalReference) throws -> Altitude {
        try requireSameContext(as: other)

        let u = max(0.0, min(1.0, t))

        let a = try self.value(in: ref).converted(to: .meters).value
        let b = try other.value(in: ref).converted(to: .meters).value
        let v = a + (b - a) * u
        let m = Measurement<UnitLength>(value: v, unit: .meters)

        return Altitude(value: m, reference: ref, context: self.context)
    }

    private func requireSameContext(as other: Altitude) throws {
        // Replace with a real comparison once you have Equatable or a compatibility check.
        // For now, this is the conceptual guard:
        guard self.context == other.context else {
            throw AltitudeArithmeticError.mismatchedContext
        }
    }
}

public enum AltitudeArithmeticError: Error {
    case mismatchedContext
}
