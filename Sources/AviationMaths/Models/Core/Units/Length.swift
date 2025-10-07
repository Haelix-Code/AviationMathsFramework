import Foundation

public struct Length: Equatable, Sendable {
    fileprivate let underlyingMeasurement: Measurement<UnitLength>

    public init(value: Double, unit: UnitLength) {
        self.underlyingMeasurement = .init(value: value, unit: unit)
    }

    public init(_ measurement: Measurement<UnitLength>) {
        self.underlyingMeasurement = measurement
    }

    public init(meters: Double) {
        self.underlyingMeasurement = .init(value: meters, unit: .meters)
    }

    public init(feet: Double) {
        self.underlyingMeasurement = .init(value: feet, unit: .feet)
    }

    public init(nauticalMiles: Double) {
        self.underlyingMeasurement = .init(value: nauticalMiles, unit: .nauticalMiles)
    }

    public var feet: Double {
        underlyingMeasurement.feet
    }

    public var meters: Double {
        underlyingMeasurement.meters
    }

    public var nauticalMiles: Double {
        underlyingMeasurement.nauticalMiles
    }

    public var yards: Double {
        underlyingMeasurement.yards
    }
}

public extension Measurement<UnitLength> {
    var feet: Double {
        self.converted(to: .feet).value
    }

    var meters: Double {
        self.converted(to: .meters).value
    }

    var nauticalMiles: Double {
        self.converted(to: .nauticalMiles).value
    }

    var yards: Double {
        self.converted(to: .yards).value
    }
}

public enum UnitSystem: String, CaseIterable, CustomStringConvertible {
    case metric, imperial

    public var description: String {
        switch self {
        case .metric:
            return "Meters"
        case .imperial:
            return "Yards"
        }
    }
}

public typealias Distance = Length
public typealias Elevation = Length

extension Length: Encodable {
    enum CodingKeys: String, CodingKey {
            case value
            case unit
        }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(underlyingMeasurement.value, forKey: .value)
        try container.encode(underlyingMeasurement.unit.symbol, forKey: .unit)
    }
}

extension Length: Decodable {
    enum Unit: String, Codable {
        case meters = "m"
        case yards = "yds"
        case feet = "ft"
        case nauticalMiles = "nm"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let unit = try values.decode(Unit.self, forKey: .unit)
        let value = try values.decode(Double.self, forKey: .value)

        let unitLength: UnitLength
        switch unit {
        case .meters:
            unitLength = .meters
        case .yards:
            unitLength = .yards
        case .feet:
            unitLength = .feet
        case .nauticalMiles:
            unitLength = .nauticalMiles
        }

        self.underlyingMeasurement = .init(value: value, unit: unitLength)
    }
}
