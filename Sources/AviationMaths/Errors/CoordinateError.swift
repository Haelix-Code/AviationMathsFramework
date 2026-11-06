import Foundation

/// A latitude or longitude outside its valid range, or not a finite number.
public enum CoordinateError: Error, Equatable, Sendable, LocalizedError {
    case latitudeOutOfRange(Double)
    case longitudeOutOfRange(Double)

    public var errorDescription: String? {
        switch self {
        case .latitudeOutOfRange(let value):
            return "Latitude must be between -90° and +90°, got \(value)°"
        case .longitudeOutOfRange(let value):
            return "Longitude must be between -180° and +180°, got \(value)°"
        }
    }
}
