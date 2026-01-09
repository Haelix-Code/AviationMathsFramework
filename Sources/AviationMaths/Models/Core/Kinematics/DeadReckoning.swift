import Foundation

/// Utility methods for dead reckoning calculations.
///
/// Dead reckoning is the process of calculating current or future position
/// by applying known velocity to a known starting position over time.
///
/// All methods in this type assume constant velocity (no acceleration,
/// no wind changes, no course alterations).
public enum DeadReckoning {
    
    // MARK: - Position Propagation
    
    /// Calculate position after traveling for a given duration.
    ///
    /// - Parameters:
    ///   - from: Starting position
    ///   - track: Direction of travel (clockwise from North)
    ///   - groundspeed: Speed over the ground
    ///   - duration: Time of travel
    /// - Returns: The resulting position
    public static func position(
        from start: RelativePosition,
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>,
        duration: Measurement<UnitDuration>
    ) -> RelativePosition {
        let velocity = Velocity2D(track: track, groundspeed: groundspeed)
        let displacement = velocity.displacement(over: duration)
        return start + displacement
    }
    
    /// Calculate position after traveling for a given duration in seconds.
    public static func position(
        from start: RelativePosition,
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>,
        seconds: Double
    ) -> RelativePosition {
        position(
            from: start,
            track: track,
            groundspeed: groundspeed,
            duration: Measurement(value: seconds, unit: .seconds)
        )
    }
    
    /// Calculate position from origin after traveling for a given duration.
    public static func position(
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>,
        duration: Measurement<UnitDuration>
    ) -> RelativePosition {
        position(from: .zero, track: track, groundspeed: groundspeed, duration: duration)
    }
    
    // MARK: - Distance and Time
    
    /// Calculate distance traveled over a given duration at a given speed.
    public static func distance(
        groundspeed: Measurement<UnitSpeed>,
        duration: Measurement<UnitDuration>
    ) -> Measurement<UnitLength> {
        let speedMPS = groundspeed.converted(to: .metersPerSecond).value
        let seconds = duration.converted(to: .seconds).value
        return Measurement(value: speedMPS * seconds, unit: UnitLength.meters)
    }
    
    /// Calculate time required to travel a given distance at a given speed.
    ///
    /// - Returns: Duration, or nil if groundspeed is zero
    public static func duration(
        distance: Measurement<UnitLength>,
        groundspeed: Measurement<UnitSpeed>
    ) -> Measurement<UnitDuration>? {
        let speedMPS = groundspeed.converted(to: .metersPerSecond).value
        guard speedMPS > 0 else { return nil }
        
        let distanceMeters = distance.converted(to: .meters).value
        let seconds = distanceMeters / speedMPS
        return Measurement(value: seconds, unit: UnitDuration.seconds)
    }
    
    /// Calculate groundspeed required to cover a distance in a given duration.
    ///
    /// - Returns: Groundspeed, or nil if duration is zero
    public static func groundspeed(
        distance: Measurement<UnitLength>,
        duration: Measurement<UnitDuration>
    ) -> Measurement<UnitSpeed>? {
        let seconds = duration.converted(to: .seconds).value
        guard seconds > 0 else { return nil }
        
        let distanceMeters = distance.converted(to: .meters).value
        let speedMPS = distanceMeters / seconds
        return Measurement(value: speedMPS, unit: UnitSpeed.metersPerSecond)
    }
    
    // MARK: - Waypoint/Track Calculations
    
    /// Calculate the track and distance from one position to another.
    ///
    /// - Parameters:
    ///   - from: Starting position
    ///   - to: Destination position
    /// - Returns: Tuple of (track angle, distance)
    public static func trackAndDistance(
        from start: RelativePosition,
        to destination: RelativePosition
    ) -> (track: Measurement<UnitAngle>, distance: Measurement<UnitLength>) {
        let delta = destination - start
        return (delta.bearing, delta.range)
    }
    
    /// Calculate time to reach a destination at a given groundspeed.
    ///
    /// - Returns: Duration to reach destination, or nil if groundspeed is zero
    public static func timeToDestination(
        from start: RelativePosition,
        to destination: RelativePosition,
        groundspeed: Measurement<UnitSpeed>
    ) -> Measurement<UnitDuration>? {
        let (_, distance) = trackAndDistance(from: start, to: destination)
        return duration(distance: distance, groundspeed: groundspeed)
    }
    
    /// Calculate when an aircraft will reach a certain range from origin.
    ///
    /// - Parameters:
    ///   - state: Current kinematic state
    ///   - range: Target range from origin
    /// - Returns: Time to reach range (positive = future), or nil if never reached
    ///
    /// Note: May return two times if aircraft passes through the range twice.
    public static func timeToRange(
        state: KinematicState2D,
        range: Measurement<UnitLength>
    ) -> [TimeInterval] {
        // This is a line-circle intersection problem
        // Position at time t: P(t) = P0 + V*t
        // We want |P(t)| = range
        // |P0 + V*t|² = range²
        // (P0x + Vx*t)² + (P0y + Vy*t)² = r²
        // Expanding: (Vx² + Vy²)t² + 2(P0x*Vx + P0y*Vy)t + (P0x² + P0y²) - r² = 0
        // This is quadratic: at² + bt + c = 0
        
        let p0x = state.position.x.converted(to: .meters).value
        let p0y = state.position.y.converted(to: .meters).value
        let vx = state.velocity.vx.converted(to: .metersPerSecond).value
        let vy = state.velocity.vy.converted(to: .metersPerSecond).value
        let r = range.converted(to: .meters).value
        
        let a = vx * vx + vy * vy
        let b = 2 * (p0x * vx + p0y * vy)
        let c = p0x * p0x + p0y * p0y - r * r
        
        // If stationary
        if a < 1e-10 {
            // Check if already at range
            let currentRange = sqrt(p0x * p0x + p0y * p0y)
            if abs(currentRange - r) < 1.0 { // Within 1 meter
                return [0]
            }
            return []
        }
        
        let discriminant = b * b - 4 * a * c
        
        if discriminant < 0 {
            // Never reaches this range
            return []
        } else if discriminant < 1e-10 {
            // Tangent - reaches range at exactly one time
            return [-b / (2 * a)]
        } else {
            // Two crossing times
            let sqrtD = sqrt(discriminant)
            let t1 = (-b - sqrtD) / (2 * a)
            let t2 = (-b + sqrtD) / (2 * a)
            return [t1, t2].sorted()
        }
    }
}
