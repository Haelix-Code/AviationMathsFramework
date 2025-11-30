import Foundation

extension Measurement<UnitAngle> {
    public var reciprocal: Measurement<UnitAngle> {
        Measurement(value: self.degrees + 180, unit: .degrees).normalized
    }

    public var perpendiculars: [Measurement<UnitAngle>] {
        return [
            Measurement(value: self.degrees + 90, unit: .degrees).normalized,
            Measurement(value: self.degrees - 90, unit: .degrees).normalized
        ]
    }
}
