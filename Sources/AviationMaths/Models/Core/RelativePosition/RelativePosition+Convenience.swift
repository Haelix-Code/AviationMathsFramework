import Foundation

public extension RelativePosition {
    /// Calculate the bearing from this position to another position.
    ///
    /// - Parameter destination: The target position
    /// - Returns: Bearing in aviation convention (0° = North, clockwise positive)
    func bearing(to destination: RelativePosition) -> Measurement<UnitAngle> {
        let deltaX = destination.x.meters - self.x.meters
        let deltaY = destination.y.meters - self.y.meters
        
        // atan2(x, y) for aviation convention (0° = North, clockwise)
        let bearingRadians = atan2(deltaX, deltaY)
        return Measurement<UnitAngle>(radians: bearingRadians).normalized
    }
}
