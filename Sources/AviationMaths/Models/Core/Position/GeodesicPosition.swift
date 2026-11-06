import Foundation

// MARK: - GeodeticOrigin

/// A reference point for converting relative positions to geodetic coordinates.
public final class GeodeticOrigin: @unchecked Sendable, Equatable, Hashable {
    public let position: Position2D

    public init(_ position: Position2D) {
        self.position = position
    }

    public static func == (lhs: GeodeticOrigin, rhs: GeodeticOrigin) -> Bool {
        lhs.position == rhs.position
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }
}

// MARK: - GeodesicPosition

/// A position expressible as both relative (bearing/range) and geodetic (lat/lon).
public struct GeodesicPosition: Sendable, Equatable {
    public let relative: RelativePosition
    public let origin: GeodeticOrigin

    public init(relative: RelativePosition, origin: GeodeticOrigin) {
        self.relative = relative
        self.origin = origin
    }

    public init(bearing: Measurement<UnitAngle>, range: Measurement<UnitLength>, origin: GeodeticOrigin) {
        self.relative = RelativePosition(bearing: bearing, range: range)
        self.origin = origin
    }

    public var geodetic: Position2D {
        relative.position(relativeTo: origin.position)
    }

    public var bearing: Measurement<UnitAngle> { relative.bearing }
    public var range: Measurement<UnitLength> { relative.range }
    public var cartesianVector: CartesianVector<UnitLength> { relative.cartesianVector }
}

extension GeodesicPosition {
    /// The vector sum of positions that share an origin.
    /// - Throws: `GeodesicPositionError.empty` for no positions, or `.mismatchedOrigins` when
    ///   they don't all share the first one's origin (their vectors can't simply be added).
    public init(summing positions: [GeodesicPosition]) throws(GeodesicPositionError) {
        guard let first = positions.first else {
            throw .empty
        }
        guard positions.allSatisfy({ $0.origin == first.origin }) else {
            throw .mismatchedOrigins
        }
        self.relative = RelativePosition(summing: positions.map(\.relative))
        self.origin = first.origin
    }

    public init(summing relatives: [RelativePosition], origin: GeodeticOrigin) {
        self.relative = RelativePosition(summing: relatives)
        self.origin = origin
    }
}

extension RelativePosition {
    public func position(from origin: GeodeticOrigin) -> GeodesicPosition {
        GeodesicPosition(relative: self, origin: origin)
    }
}

public enum GeodesicPositionError: Error, Equatable, Sendable, LocalizedError {
    case empty
    case mismatchedOrigins

    public var errorDescription: String? {
        switch self {
        case .empty: return "There are no positions to sum"
        case .mismatchedOrigins: return "Positions with different origins can't be summed"
        }
    }
}
