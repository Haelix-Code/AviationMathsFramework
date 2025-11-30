import Foundation

public struct WindTriangle: Sendable {
    /// Calculate groundspeed vector from TAS, track, and wind
    /// - Parameters:
    /// - tas: True airspeed magnitude
    /// - track: Track direction (bearing aircraft is traveling over ground)
    /// - wind: Wind conditions
    /// - Returns: Groundspeed as a Cartesian vector
    public static func groundspeed(
    tas: Measurement<UnitSpeed>,
    track: Measurement<UnitAngle>,
    wind: Wind
    ) -> CartesianVector<UnitSpeed> {
        // Aircraft velocity vector (TAS in direction of track)
        let aircraftPolar = SpeedPolar(bearing: track, magnitude: tas)
        let aircraftVector = aircraftPolar.asCartesianVector
        
        // Wind vector (already gives us direction wind is pushing)
        let windVector = wind.vector
        // Groundspeed = aircraft velocity + wind velocity
        return aircraftVector + windVector
    }
    
    /// Calculate groundspeed and track from TAS, heading, and wind
    /// - Parameters:
    /// - tas: True airspeed magnitude
    /// - heading: Heading (direction aircraft nose points)
    /// - wind: Wind conditions
    /// - Returns: Groundspeed as a polar vector (magnitude and track)
    public static func groundspeedPolar(
         tas: Measurement<UnitSpeed>,
         heading: Measurement<UnitAngle>,
         wind: Wind
         ) -> SpeedPolar {
         let gsVector = groundspeed(tas: tas, track: heading, wind: wind)
         return gsVector.asPolar
    }
}
