import Foundation

public extension Measurement<UnitAngle> {
    init(degrees value: Double) { self.init(value: value, unit: .degrees) }

    init(radians value: Double) { self.init(value: value, unit: .radians) }

    var degrees: Double {
        self.converted(to: .degrees).value
    }

    var radians: Double {
        self.converted(to: .radians).value
    }

    /// Normalize bearing to 0..<360 degrees
    var normalized: Measurement<UnitAngle> {
        var degrees = self.converted(to: .degrees).value
        degrees = degrees.truncatingRemainder(dividingBy: 360)
        if degrees < 0 { degrees += 360 }
        // For a tiny negative input (e.g. -1e-14, reachable from atan2 noise), adding 360
        // can round to exactly 360.0 rather than just under it, violating the 0..<360 contract.
        if degrees >= 360 { degrees -= 360 }
        return Measurement(value: degrees, unit: .degrees)
    }

    /// Normalize to -180...180 range (for signed differences)
    var normalizedSigned: Measurement<UnitAngle> {
        var degrees = self.converted(to: .degrees).value
        degrees = degrees.truncatingRemainder(dividingBy: 360)
        if degrees > 180 { degrees -= 360 }
        if degrees <= -180 { degrees += 360 }
        return Measurement(value: degrees, unit: .degrees)
    }
}
