import Foundation

public enum LatitudeDirection: String, Codable, CaseIterable, Sendable {
    case north = "N"
    case south = "S"

    public var sign: Double {
        switch self {
        case .north: return 1.0
        case .south: return -1.0
        }
    }

    public init(decimalDegrees: Double) {
        self = decimalDegrees >= 0 ? .north : .south
    }

    public var name: String {
        switch self {
        case .north: return "North"
        case .south: return "South"
        }
    }
}

public enum LongitudeDirection: String, Codable, CaseIterable, Sendable {
    case east = "E"
    case west = "W"
    
    public var sign: Double {
        switch self {
        case .east: return 1.0
        case .west: return -1.0
        }
    }
    
    public init(decimalDegrees: Double) {
        self = decimalDegrees >= 0 ? .east : .west
    }
    
    public var name: String {
        switch self {
        case .east: return "East"
        case .west: return "West"
        }
    }
}

extension LongitudeDirection {
    /// Convert to/from compass bearing (0-360°)
    ///
    /// In aviation, bearings are typically 0-360° where 0° is North and increases clockwise.
    /// This helper converts between signed longitude (-180 to +180) and compass bearing.
    ///
    /// - Parameter bearing: Bearing in degrees (0-360)
    /// - Returns: Corresponding longitude direction
    public static func from(bearing: Double) -> LongitudeDirection {
        let normalized = bearing.truncatingRemainder(dividingBy: 360)
        return (normalized > 180 || (normalized < 0 && normalized > -180)) ? .west : .east
    }
}

extension LatitudeDirection: CustomStringConvertible {
    public var description: String { rawValue }
}

extension LongitudeDirection: CustomStringConvertible {
    public var description: String { rawValue }
}
