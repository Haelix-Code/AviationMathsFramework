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

        // Interpolate speed (simple linear)
        let speedInterp = lower.speed.knots + fraction * (upper.speed.knots - lower.speed.knots)

        // Interpolate direction (handle 360° wrap)
        var dirDiff = upper.fromDirection.degrees - lower.fromDirection.degrees
        if dirDiff > 180 { dirDiff -= 360 }
        if dirDiff < -180 { dirDiff += 360 }
        var dirInterp = lower.fromDirection.degrees + fraction * dirDiff
        if dirInterp < 0 { dirInterp += 360 }
        if dirInterp >= 360 { dirInterp -= 360 }

        return Wind(
            altitude: altitude,
            fromDirection: .init(degrees: dirInterp),
            speed: .init(knots: speedInterp)
        )
    }
}
