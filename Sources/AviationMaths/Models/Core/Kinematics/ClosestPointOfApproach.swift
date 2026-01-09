import Foundation

/// Result of a closest point of approach calculation.
public struct CPAResult: Sendable, Equatable {
    
    /// Time of closest approach (relative to the reference time).
    /// Negative values indicate CPA was in the past.
    public let timeToCPA: TimeInterval
    
    /// The absolute time of CPA (if reference times were provided).
    public let cpaTime: TimeInterval
    
    /// Miss distance at CPA.
    public let missDistance: Measurement<UnitLength>
    
    /// Position of ownship at CPA.
    public let ownshipPositionAtCPA: RelativePosition
    
    /// Position of target at CPA.
    public let targetPositionAtCPA: RelativePosition
    
    /// Whether the aircraft are currently converging (CPA in future).
    public var isConverging: Bool { timeToCPA > 0 }
    
    /// Whether the aircraft are currently diverging (CPA in past).
    public var isDiverging: Bool { timeToCPA < 0 }
    
    /// Whether they're at CPA right now (within tolerance).
    public var isAtCPA: Bool { abs(timeToCPA) < 0.1 }
    
    /// The relative position of target from ownship at CPA.
    public var relativePositionAtCPA: RelativePosition {
        targetPositionAtCPA - ownshipPositionAtCPA
    }
    
    /// Bearing from ownship to target at CPA.
    public var bearingAtCPA: Measurement<UnitAngle> {
        relativePositionAtCPA.bearing
    }
}

/// Indicates why a CPA calculation could not produce a meaningful result.
public enum CPACondition: Sendable, Equatable {
    /// Both aircraft have the same velocity (parallel tracks, constant separation).
    case parallelTracks(constantSeparation: Measurement<UnitLength>)
    
    /// Both aircraft are stationary.
    case bothStationary(separation: Measurement<UnitLength>)
    
    /// Aircraft are co-located and have the same velocity.
    case coLocatedSameVelocity
}

/// The result of a CPA calculation, either a valid result or a special condition.
public enum CPAOutcome: Sendable, Equatable {
    case valid(CPAResult)
    case noValidCPA(CPACondition)
    
    /// Convenience accessor for valid results.
    public var result: CPAResult? {
        if case .valid(let result) = self { return result }
        return nil
    }
    
    /// Convenience accessor for conditions.
    public var condition: CPACondition? {
        if case .noValidCPA(let condition) = self { return condition }
        return nil
    }
    
    /// Whether this represents a valid CPA.
    public var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
}

/// Calculator for closest point of approach between two aircraft.
///
/// Given two kinematic states (position + velocity), this calculates when
/// and where they will be (or were) closest to each other, assuming both
/// maintain constant velocity.
///
/// ## Mathematical Basis
///
/// For aircraft A at position Pa with velocity Va, and aircraft B at Pb with Vb:
///
/// - Position at time t: Pa(t) = Pa + Va × t, Pb(t) = Pb + Vb × t
/// - Relative position: Pr(t) = Pb(t) - Pa(t) = (Pb - Pa) + (Vb - Va) × t
/// - Let Pr₀ = Pb - Pa (initial relative position)
/// - Let Vr = Vb - Va (relative velocity)
/// - Then: Pr(t) = Pr₀ + Vr × t
///
/// The squared distance is: |Pr(t)|² = |Pr₀|² + 2(Pr₀ · Vr)t + |Vr|²t²
///
/// Minimizing (derivative = 0): t_cpa = -(Pr₀ · Vr) / |Vr|²
///
public enum ClosestPointOfApproach {
    
    /// Calculate the closest point of approach between two aircraft.
    ///
    /// - Parameters:
    ///   - ownship: The reference aircraft's state
    ///   - target: The other aircraft's state
    /// - Returns: The CPA outcome (either valid result or special condition)
    ///
    /// Both states should use the same reference time. If they don't,
    /// the target is propagated to ownship's reference time first.
    public static func calculate(
        ownship: KinematicState2D,
        target: KinematicState2D
    ) -> CPAOutcome {
        
        // Align reference times - propagate target to ownship's time
        let alignedTarget: KinematicState2D
        if target.referenceTime != ownship.referenceTime {
            alignedTarget = target.state(at: ownship.referenceTime)
        } else {
            alignedTarget = target
        }
        
        // Calculate relative position and velocity
        let relativePosition = alignedTarget.position - ownship.position
        let relativeVelocity = alignedTarget.velocity - ownship.velocity
        
        // Get components in meters and m/s
        let pr0x = relativePosition.x.converted(to: .meters).value
        let pr0y = relativePosition.y.converted(to: .meters).value
        let vrx = relativeVelocity.vx.converted(to: .metersPerSecond).value
        let vry = relativeVelocity.vy.converted(to: .metersPerSecond).value
        
        // |Vr|² - squared magnitude of relative velocity
        let vrSquared = vrx * vrx + vry * vry
        
        // Check for parallel tracks (same velocity)
        let velocityThreshold = 0.01 // (m/s)² - about 0.1 m/s
        if vrSquared < velocityThreshold {
            let separation = relativePosition.range
            
            // Check if both stationary
            if ownship.isStationary && alignedTarget.isStationary {
                if separation.converted(to: .meters).value < 1.0 {
                    return .noValidCPA(.coLocatedSameVelocity)
                }
                return .noValidCPA(.bothStationary(separation: separation))
            }
            
            // Parallel tracks - constant separation
            return .noValidCPA(.parallelTracks(constantSeparation: separation))
        }
        
        // Pr₀ · Vr - dot product
        let dotProduct = pr0x * vrx + pr0y * vry
        
        // t_cpa = -(Pr₀ · Vr) / |Vr|²
        let timeToCPA = -dotProduct / vrSquared
        
        // Calculate positions at CPA
        let ownshipAtCPA = ownship.position(after: timeToCPA)
        let targetAtCPA = alignedTarget.position(after: timeToCPA)
        
        // Miss distance
        let missDistance = (targetAtCPA - ownshipAtCPA).range
        
        return .valid(CPAResult(
            timeToCPA: timeToCPA,
            cpaTime: ownship.referenceTime + timeToCPA,
            missDistance: missDistance,
            ownshipPositionAtCPA: ownshipAtCPA,
            targetPositionAtCPA: targetAtCPA
        ))
    }
    
    /// Calculate CPA with positions specified as bearing/range from a common origin.
    ///
    /// This is a convenience method for radar-style inputs.
    public static func calculate(
        ownshipBearing: Measurement<UnitAngle>,
        ownshipRange: Measurement<UnitLength>,
        ownshipTrack: Measurement<UnitAngle>,
        ownshipGroundspeed: Measurement<UnitSpeed>,
        targetBearing: Measurement<UnitAngle>,
        targetRange: Measurement<UnitLength>,
        targetTrack: Measurement<UnitAngle>,
        targetGroundspeed: Measurement<UnitSpeed>
    ) -> CPAOutcome {
        
        let ownship = KinematicState2D(
            bearing: ownshipBearing,
            range: ownshipRange,
            track: ownshipTrack,
            groundspeed: ownshipGroundspeed
        )
        
        let target = KinematicState2D(
            bearing: targetBearing,
            range: targetRange,
            track: targetTrack,
            groundspeed: targetGroundspeed
        )
        
        return calculate(ownship: ownship, target: target)
    }
}

// MARK: - CPAResult Convenience

extension CPAResult {
    
    /// Format time to CPA as a human-readable string.
    public var formattedTimeToCPA: String {
        let absTime = abs(timeToCPA)
        let prefix = timeToCPA < 0 ? "-" : ""
        
        if absTime < 60 {
            return String(format: "%@%.0fs", prefix, absTime)
        } else if absTime < 3600 {
            let minutes = Int(absTime / 60)
            let seconds = Int(absTime.truncatingRemainder(dividingBy: 60))
            return String(format: "%@%dm %02ds", prefix, minutes, seconds)
        } else {
            let hours = Int(absTime / 3600)
            let minutes = Int((absTime.truncatingRemainder(dividingBy: 3600)) / 60)
            return String(format: "%@%dh %02dm", prefix, hours, minutes)
        }
    }
}
