import Foundation

public struct Angle: Equatable {
    fileprivate let underlyingMeasurement: Measurement<UnitAngle>

    public init(_ measurement: Measurement<UnitAngle>) {
        self.underlyingMeasurement = measurement
    }

    public init(value: Double, unit: UnitAngle) {
        self.underlyingMeasurement = .init(value: value, unit: unit)
    }

    public init(degrees: Double) {
        self.underlyingMeasurement = .init(value: degrees, unit: .degrees)
    }

    public init(radians: Double) {
        self.underlyingMeasurement = .init(value: radians, unit: .radians)
    }

    public var degrees: Double {
        underlyingMeasurement.converted(to: .degrees).value
    }

    public var radians: Double {
        underlyingMeasurement.converted(to: .radians).value
    }

    public func description(_ unitAngle: UnitAngle = .degrees) -> String {
        underlyingMeasurement.converted(to: unitAngle).description
    }
}

extension Angle: Encodable {
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

extension Angle: Decodable {
    enum Units: String, Codable {
        case radians = "rad"
        case degrees = "°"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let unit = try values.decode(Units.self, forKey: .unit)
        let value = try values.decode(Double.self, forKey: .value)

        let unitAngle: UnitAngle
        switch unit {
        case .radians:
            unitAngle = .radians
        case .degrees:
            unitAngle = .degrees
        }

        self.underlyingMeasurement = .init(value: value, unit: unitAngle)
    }
}
