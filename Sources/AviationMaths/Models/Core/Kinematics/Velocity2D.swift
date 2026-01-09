import Foundation

/// A 2D velocity vector representing motion across the ground.
///
/// This uses track (direction of travel over ground) and groundspeed,
/// which is the appropriate representation when wind effects have already
/// been accounted for, or when working with no-wind scenarios.
///
/// For scenarios requiring wind triangle calculations, use `WindTriangle`
/// to compute track and groundspeed from heading, TAS, and wind.
public struct Velocity2D: Sendable, Equatable {
    
    /// The track angle (direction of travel, measured clockwise from North).
    public let track: Measurement<UnitAngle>
    
    /// The groundspeed (speed over the ground).
    public let groundspeed: Measurement<UnitSpeed>
    
    // MARK: - Initialization
    
    public init(track: Measurement<UnitAngle>, groundspeed: Measurement<UnitSpeed>) {
        self.track = track.normalized
        self.groundspeed = groundspeed
    }
    
    /// Initialize from Cartesian velocity components.
    /// - Parameters:
    ///   - vx: East-West velocity component (positive = East)
    ///   - vy: North-South velocity component (positive = North)
    public init(vx: Measurement<UnitSpeed>, vy: Measurement<UnitSpeed>) {
        let cartesian = SpeedCartesianVector(x: vx, y: vy)
        let polar = cartesian.asPolar
        self.track = polar.bearing.normalized
        self.groundspeed = polar.magnitude
    }
    
    /// Initialize from a SpeedCartesianVector.
    public init(cartesian: SpeedCartesianVector) {
        let polar = cartesian.asPolar
        self.track = polar.bearing.normalized
        self.groundspeed = polar.magnitude
    }
    
    // MARK: - Conversions
    
    /// The velocity as a Cartesian vector (vx = East, vy = North).
    public var cartesian: SpeedCartesianVector {
        SpeedPolar(bearing: track, magnitude: groundspeed).asCartesianVector
    }
    
    /// East-West velocity component (positive = moving East).
    public var vx: Measurement<UnitSpeed> { cartesian.x }
    
    /// North-South velocity component (positive = moving North).
    public var vy: Measurement<UnitSpeed> { cartesian.y }
    
    // MARK: - Displacement
    
    /// Calculate displacement over a time interval.
    ///
    /// - Parameter duration: Time interval (positive for future, negative for past)
    /// - Returns: The displacement as a RelativePosition
    public func displacement(over duration: Measurement<UnitDuration>) -> RelativePosition {
        let seconds = duration.converted(to: .seconds).value
        let distanceMeters = groundspeed.converted(to: .metersPerSecond).value * seconds
        return RelativePosition(
            bearing: track,
            range: Measurement(value: distanceMeters, unit: UnitLength.meters)
        )
    }
    
    /// Calculate displacement over a time interval in seconds.
    public func displacement(seconds: Double) -> RelativePosition {
        displacement(over: Measurement(value: seconds, unit: .seconds))
    }
    
    // MARK: - Static
    
    /// A stationary velocity (zero groundspeed).
    public static var stationary: Velocity2D {
        Velocity2D(track: .init(degrees: 0), groundspeed: .init(knots: 0))
    }
    
    /// Check if effectively stationary (groundspeed below threshold).
    public func isStationary(threshold: Measurement<UnitSpeed> = .init(knots: 0.1)) -> Bool {
        groundspeed.converted(to: .knots).value < threshold.converted(to: .knots).value
    }
}

// MARK: - Arithmetic

extension Velocity2D {
    /// Add two velocities (vector addition).
    public static func + (lhs: Velocity2D, rhs: Velocity2D) -> Velocity2D {
        Velocity2D(cartesian: lhs.cartesian + rhs.cartesian)
    }
    
    /// Subtract two velocities (vector subtraction).
    public static func - (lhs: Velocity2D, rhs: Velocity2D) -> Velocity2D {
        Velocity2D(cartesian: lhs.cartesian - rhs.cartesian)
    }
    
    /// Negate velocity (reverse direction, same speed).
    public static prefix func - (velocity: Velocity2D) -> Velocity2D {
        Velocity2D(cartesian: -velocity.cartesian)
    }
    
    /// Scale velocity by a factor.
    public static func * (lhs: Velocity2D, rhs: Double) -> Velocity2D {
        Velocity2D(cartesian: lhs.cartesian * rhs)
    }
    
    public static func * (lhs: Double, rhs: Velocity2D) -> Velocity2D {
        rhs * lhs
    }
}
