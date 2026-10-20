import Foundation

extension Array where Element == Wind {
    /// Interpolate wind at a given altitude from a profile of winds.
    public func interpolated(at altitude: Measurement<UnitLength>) -> Wind? {
        guard !isEmpty else { return nil }

        let sorted = self.sorted { $0.altitude.meters < $1.altitude.meters }

        // Below lowest layer
        guard altitude.meters >= sorted.first!.altitude.meters else { return nil }

        // Above highest layer
        guard altitude.meters <= sorted.last!.altitude.meters else { return nil }

        // Exact match
        if let exact = sorted.first(where: { abs($0.altitude.meters - altitude.meters) < 0.1 }) {
            return exact
        }

        // Find bracketing layers
        guard let upperIndex = sorted.firstIndex(where: { $0.altitude.meters > altitude.meters }) else {
            return nil
        }
        let lowerIndex = upperIndex - 1
        let lower = sorted[lowerIndex]
        let upper = sorted[upperIndex]

        // Linear interpolation factor
        let altRange = upper.altitude.meters - lower.altitude.meters
        let fraction = (altitude.meters - lower.altitude.meters) / altRange

        // Interpolate the wind as a vector (u/v components), not speed and
        // direction separately: two winds of equal speed but different
        // direction partially (or fully) cancel, which a separate speed/
        // direction interpolation can never represent.
        let lowerVector = lower.vector
        let upperVector = upper.vector
        let interpolatedVector = lowerVector + (upperVector - lowerVector) * fraction
        let interpolatedPolar = interpolatedVector.asPolar

        return Wind(
            altitude: altitude,
            fromDirection: interpolatedPolar.bearing.reciprocal,
            speed: interpolatedPolar.magnitude
        )
    }
}
