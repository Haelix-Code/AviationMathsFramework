import Foundation

/// A 2D kinematic state representing position and velocity at a given instant.
///
/// This is the fundamental type for dead reckoning calculations, combining:
/// - Where an object is (position)
/// - How it's moving (velocity)
/// - When this state was valid (reference time)
///
/// The reference time allows propagation forwards or backwards to determine
/// state at any other time, assuming constant velocity.
public struct KinematicState2D: Sendable, Equatable {
    
    /// Position relative to some origin.
    public let position: RelativePosition
    
    /// Velocity (track and groundspeed).
    public let velocity: Velocity2D
    
    /// Reference time for this state (seconds, typically from some epoch).
    /// Positive values represent future, negative represent past.
    public let referenceTime: TimeInterval
    
    // MARK: - Initialization
    
    public init(
        position: RelativePosition,
        velocity: Velocity2D,
        referenceTime: TimeInterval = 0
    ) {
        self.position = position
        self.velocity = velocity
        self.referenceTime = referenceTime
    }
    
    /// Create a state at the origin, moving in a given direction.
    public init(
        velocity: Velocity2D,
        referenceTime: TimeInterval = 0
    ) {
        self.position = .zero
        self.velocity = velocity
        self.referenceTime = referenceTime
    }
    
    /// Create a stationary state at a given position.
    public init(
        position: RelativePosition,
        referenceTime: TimeInterval = 0
    ) {
        self.position = position
        self.velocity = .stationary
        self.referenceTime = referenceTime
    }
    
    // MARK: - Convenience Initializers
    
    /// Create a state from bearing/range position and track/groundspeed.
    public init(
        bearing: Measurement<UnitAngle>,
        range: Measurement<UnitLength>,
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>,
        referenceTime: TimeInterval = 0
    ) {
        self.position = RelativePosition(bearing: bearing, range: range)
        self.velocity = Velocity2D(track: track, groundspeed: groundspeed)
        self.referenceTime = referenceTime
    }
    
    /// Create a state from x/y position and track/groundspeed.
    public init(
        x: Measurement<UnitLength>,
        y: Measurement<UnitLength>,
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>,
        referenceTime: TimeInterval = 0
    ) {
        self.position = RelativePosition(x: x, y: y)
        self.velocity = Velocity2D(track: track, groundspeed: groundspeed)
        self.referenceTime = referenceTime
    }
    
    // MARK: - Properties
    
    /// Whether this state represents a stationary object.
    public var isStationary: Bool {
        velocity.isStationary()
    }
    
    /// The track angle (direction of travel).
    public var track: Measurement<UnitAngle> { velocity.track }
    
    /// The groundspeed.
    public var groundspeed: Measurement<UnitSpeed> { velocity.groundspeed }
}

// MARK: - State at Different Times

extension KinematicState2D {
    
    /// Calculate the state at a different time, assuming constant velocity.
    ///
    /// - Parameter time: The target time (same epoch as referenceTime)
    /// - Returns: The propagated state at the target time
    public func state(at time: TimeInterval) -> KinematicState2D {
        let deltaTime = time - referenceTime
        let displacement = velocity.displacement(seconds: deltaTime)
        let newPosition = position + displacement
        
        return KinematicState2D(
            position: newPosition,
            velocity: velocity,
            referenceTime: time
        )
    }
    
    /// Calculate the state after a duration from the reference time.
    ///
    /// - Parameter duration: Time to propagate (positive = future, negative = past)
    /// - Returns: The propagated state
    public func state(after duration: TimeInterval) -> KinematicState2D {
        state(at: referenceTime + duration)
    }
    
    /// Calculate the state after a duration from the reference time.
    public func state(after duration: Measurement<UnitDuration>) -> KinematicState2D {
        state(after: duration.converted(to: .seconds).value)
    }
    
    /// Calculate only the position at a different time.
    ///
    /// - Parameter time: The target time
    /// - Returns: The position at that time
    public func position(at time: TimeInterval) -> RelativePosition {
        let deltaTime = time - referenceTime
        let displacement = velocity.displacement(seconds: deltaTime)
        return position + displacement
    }
    
    /// Calculate only the position after a duration.
    public func position(after duration: TimeInterval) -> RelativePosition {
        position(at: referenceTime + duration)
    }
}

// MARK: - Relative Calculations

extension KinematicState2D {
    
    /// Calculate this state relative to another state at a given time.
    ///
    /// Returns the position and velocity of self as seen from the other state.
    /// Both states are first propagated to the given time.
    ///
    /// - Parameters:
    ///   - other: The reference state
    ///   - time: The time at which to compute the relative state
    /// - Returns: This state expressed relative to the other
    public func relative(to other: KinematicState2D, at time: TimeInterval) -> KinematicState2D {
        let selfAtTime = self.state(at: time)
        let otherAtTime = other.state(at: time)
        
        let relativePosition = selfAtTime.position - otherAtTime.position
        let relativeVelocity = selfAtTime.velocity - otherAtTime.velocity
        
        return KinematicState2D(
            position: relativePosition,
            velocity: relativeVelocity,
            referenceTime: time
        )
    }
    
    /// Calculate the range (distance) to another state at a given time.
    public func range(to other: KinematicState2D, at time: TimeInterval) -> Measurement<UnitLength> {
        let selfPos = self.position(at: time)
        let otherPos = other.position(at: time)
        return (selfPos - otherPos).range
    }
    
    /// Calculate the bearing to another state at a given time.
    public func bearing(to other: KinematicState2D, at time: TimeInterval) -> Measurement<UnitAngle> {
        let selfPos = self.position(at: time)
        let otherPos = other.position(at: time)
        return (otherPos - selfPos).bearing
    }
}
