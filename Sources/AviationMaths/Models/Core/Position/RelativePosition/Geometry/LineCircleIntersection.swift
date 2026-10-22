import Foundation

/// Result of intersecting a line with a circle.
public struct LineCircleIntersection: Sendable, Equatable {
    /// Parameter values where line intersects circle (0, 1, or 2 values).
    /// For line P(t) = origin + t × direction, these are the `t` values.
    public let parameters: [Double]

    /// Whether the line is tangent to the circle (single intersection).
    public var isTangent: Bool { parameters.count == 1 }

    /// Whether the line misses the circle entirely.
    public var misses: Bool { parameters.isEmpty }

    /// Whether the line passes through the circle (two intersections).
    public var passesThrough: Bool { parameters.count == 2 }
}

public enum LineCircle {
    /// Intersects a parametric line with a circle.
    ///
    /// The line is defined as `P(t) = origin + t × direction` where `direction`
    /// is a unit vector. Parameter `t` represents distance along the line in
    /// the same units as `radius`.
    ///
    /// - Parameters:
    ///   - lineOrigin: Starting point of the parametric line (in meters from reference).
    ///   - lineDirection: Unit vector direction of the line.
    ///   - circleCentre: Centre of the circle (in meters from same reference).
    ///   - radius: Circle radius in meters.
    /// - Returns: Intersection result with parameter values sorted ascending.
    public static func intersect(
        lineOrigin: RelativePosition,
        lineDirection: RelativePosition,
        circleCentre: RelativePosition,
        radius: Measurement<UnitLength>
    ) -> LineCircleIntersection {
        // Vector from line origin to circle centre
        let f = RelativePosition(
            x: lineOrigin.x - circleCentre.x,
            y: lineOrigin.y - circleCentre.y
        )

        let d = lineDirection
        let R = radius.converted(to: .meters).value

        // Quadratic coefficients: at² + bt + c = 0
        let a = d.x.meters * d.x.meters + d.y.meters * d.y.meters
        let b = 2.0 * (d.x.meters * f.x.meters + d.y.meters * f.y.meters)
        let c = f.x.meters * f.x.meters + f.y.meters * f.y.meters - R * R

        let discriminant = b * b - 4.0 * a * c

        let tolerance = 1e-10

        if discriminant < -tolerance {
            // No intersection
            return LineCircleIntersection(parameters: [])
        } else if abs(discriminant) <= tolerance {
            // Tangent (single intersection)
            let t = -b / (2.0 * a)
            return LineCircleIntersection(parameters: [t])
        } else {
            // Two intersections
            let sqrtD = sqrt(discriminant)
            let t1 = (-b - sqrtD) / (2.0 * a)
            let t2 = (-b + sqrtD) / (2.0 * a)
            return LineCircleIntersection(parameters: [t1, t2].sorted())
        }
    }
}
