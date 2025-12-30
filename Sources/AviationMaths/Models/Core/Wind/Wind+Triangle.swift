import Foundation

public struct WindTriangle: Sendable {

    /// Calculate ground vector from air vector and wind.
    ///
    /// Solves: "Given my heading, TAS, and wind, what will my track and groundspeed be?"
    ///
    /// - Parameters:
    /// - heading: Aircraft heading (direction nose points)
    /// - tas: True airspeed
    /// - wind: Wind conditions
    /// - Returns: Ground vector as Cartesian (use `.asPolar` for track/groundspeed)
    public static func groundVector(
        heading: Measurement<UnitAngle>,
        tas: Measurement<UnitSpeed>,
        wind: Wind
    ) -> SpeedCartesianVector {
        let airVector = SpeedPolar(bearing: heading, magnitude: tas).asCartesianVector
        let windVectorToDirection = CartesianVector(bearing: wind.toDirection, magnitude: wind.speed)
        return airVector + windVectorToDirection
    }

    /// Calculate ground vector as polar coordinates (track and groundspeed).
    public static func groundVectorPolar(
        heading: Measurement<UnitAngle>,
        tas: Measurement<UnitSpeed>,
        wind: Wind
    ) -> SpeedPolar {
        groundVector(heading: heading, tas: tas, wind: wind).asPolar
    }

    /// Calculate drift angle (track minus heading).
    ///
    /// - Returns: Positive = drifting right, negative = drifting left
    public static func driftAngle(
        heading: Measurement<UnitAngle>,
        tas: Measurement<UnitSpeed>,
        wind: Wind
    ) -> Measurement<UnitAngle> {
        let ground = groundVectorPolar(heading: heading, tas: tas, wind: wind)
        let drift = ground.bearing.degrees - heading.normalized.degrees
        return Measurement(degrees: drift).normalizedSigned
    }

    /// Calculate required air vector to achieve desired ground vector.
    ///
    /// Solves: "Given my desired track and groundspeed, and the wind, what heading
    /// and TAS do I need?"
    ///
    /// - Parameters:
    /// - track: Desired track (direction over ground)
    /// - groundspeed: Desired groundspeed
    /// - wind: Wind conditions
    /// - Returns: Required air vector as Cartesian (use `.asPolar` for heading/TAS)
    public static func airVector(
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>,
        wind: Wind
    ) -> SpeedCartesianVector {
        let groundVector = SpeedPolar(bearing: track, magnitude: groundspeed).asCartesianVector
        let windVector = wind.vector
        return groundVector - windVector
    }

    /// Calculate required air vector as polar coordinates (heading and TAS).
    public static func airVectorPolar(
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>,
        wind: Wind
    ) -> SpeedPolar {
        airVector(track: track, groundspeed: groundspeed, wind: wind).asPolar
    }

    public static func headingForTrack(
        track: Measurement<UnitAngle>,
        tas: Measurement<UnitSpeed>,
        wind: Wind
    ) -> (polar: SpeedPolar, wca: Measurement<UnitAngle>)? {
        let windTo = wind.toDirection.radians
        let trackRad = track.radians
        let crosswindComponent = wind.speed.knots * sin(windTo - trackRad)

        // Check if solution exists (crosswind can't exceed TAS)
        guard abs(crosswindComponent) <= tas.knots else {
            return nil
        }

        // Wind correction angle: sin(WCA) = crosswind / TAS
        let wcaRadians = asin(crosswindComponent / tas.knots)
        let wca = Measurement<UnitAngle>(radians: -wcaRadians) // Negative because we correct into the wind

        let heading = Measurement<UnitAngle>(degrees: track.degrees + wca.degrees).normalized

        let ground = groundVectorPolar(heading: heading, tas: tas, wind: wind)

        return (polar: PolarVector(bearing: heading, magnitude: ground.magnitude), wca: wca)
    }

    public static func wind(
        heading: Measurement<UnitAngle>,
        tas: Measurement<UnitSpeed>,
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>
    ) -> Wind {
        let airVector = SpeedPolar(bearing: heading, magnitude: tas).asCartesianVector
        let groundVector = SpeedPolar(bearing: track, magnitude: groundspeed).asCartesianVector

        let windVector = groundVector - airVector
        let windPolar = windVector.asPolar

        // windPolar.bearing is the direction wind is blowing TO
        // Wind convention is direction FROM, so we need the reciprocal
        let windFrom = windPolar.bearing.reciprocal

        return Wind(
            altitude: .init(feet: 0), // Altitude unknown from this calculation
            fromDirection: windFrom,
            speed: windPolar.magnitude
        )
    }

    /// Calculate wind from observed air and ground vectors, with altitude.
    public static func wind(
        heading: Measurement<UnitAngle>,
        tas: Measurement<UnitSpeed>,
        track: Measurement<UnitAngle>,
        groundspeed: Measurement<UnitSpeed>,
        altitude: Measurement<UnitLength>
    ) -> Wind {
        let baseWind = wind(heading: heading, tas: tas, track: track, groundspeed: groundspeed)
        return Wind(
            altitude: altitude,
            fromDirection: baseWind.fromDirection,
            speed: baseWind.speed
        )
    }

    /// Calculate head/tail wind component for a given track.
    ///
    /// - Parameters:
    /// - wind: Wind conditions
    /// - track: Aircraft track (or runway heading)
    /// - Returns: Positive = headwind, negative = tailwind
    public static func headwindComponent(
        wind: Wind,
        track: Measurement<UnitAngle>
    ) -> Measurement<UnitSpeed> {
        // Headwind is the component of wind opposing the direction of travel
        let windTo = wind.toDirection.radians
        let trackRad = track.radians

        // Component along track (negative of wind in track direction)
        let component = -wind.speed.knots * cos(windTo - trackRad)
        return Measurement(knots: component)
    }

    /// Calculate crosswind component for a given track.
    ///
    /// - Parameters:
    /// - wind: Wind conditions
    /// - track: Aircraft track (or runway heading)
    /// - Returns: Positive = wind from right, negative = wind from left
    public static func crosswindComponent(
        wind: Wind,
        track: Measurement<UnitAngle>
    ) -> Measurement<UnitSpeed> {
        let windTo = wind.toDirection.radians
        let trackRad = track.radians

        // Component perpendicular to track
        // Positive when wind pushes from right (wind from right = positive)
        let component = -wind.speed.knots * sin(windTo - trackRad)
        return Measurement(knots: component)
    }

    /// Simple groundspeed calculation:
    /// GS ≈ TAS − headwindComponent
    ///
    /// - Wind direction is FROM (meteorological)
    /// - Positive headwind reduces GS
    /// - Crosswind (±90°) contributes zero
    ///
    /// This intentionally ignores drift / WCA.
    public static func simpleGroundspeed(
        heading: Measurement<UnitAngle>,
        tas: Measurement<UnitSpeed>,
        wind: Wind
    ) -> Measurement<UnitSpeed> {
          let deltaDeg = (wind.fromDirection.degrees - heading.degrees)
          let deltaRad = Measurement<UnitAngle>(degrees: deltaDeg).normalizedSigned.radians

          // Along-track component (positive = headwind)
          let headwind = wind.speed.knots * cos(deltaRad)

          // Groundspeed ≈ TAS minus headwind
          let gsKnots = tas.knots - headwind
          return Measurement<UnitSpeed>(knots: gsKnots)
    }

}
