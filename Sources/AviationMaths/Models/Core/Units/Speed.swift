import Foundation

public struct Speed: Equatable, Sendable {
    fileprivate let underlyingMeasurement: Measurement<UnitSpeed>

    public init(_ measurement: Measurement<UnitSpeed>) {
        self.underlyingMeasurement = measurement
    }

    public init(value: Double, unit: UnitSpeed) {
        self.underlyingMeasurement = .init(value: value, unit: unit)
    }

    public init(metersPerSecond: Double) {
        self.underlyingMeasurement = .init(value: metersPerSecond, unit: .metersPerSecond)
    }

    public init(knots: Double) {
        self.underlyingMeasurement = .init(value: knots, unit: .knots)
    }

    public init(feetPerSecond: Double) {
        self.underlyingMeasurement = .init(value: feetPerSecond, unit: .feetPerSecond)
    }

    public var metersPerSecond: Double {
        underlyingMeasurement.converted(to: .metersPerSecond).value
    }

    public var knots: Double {
        underlyingMeasurement.converted(to: .knots).value
    }

    public var feetPerSecond: Double {
        underlyingMeasurement.converted(to: .feetPerSecond).value
    }

    public func description(_ unitSpeed: UnitSpeed = .knots) -> String {
        underlyingMeasurement.converted(to: unitSpeed).description
    }
}

extension Speed: Encodable {
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

extension Speed: Decodable {
    enum Units: String, Codable {
        case metersPerSecond = "m/s"
        case knots = "kn"
        case feetPerSecond = "ft/s"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let unit = try values.decode(Units.self, forKey: .unit)
        let value = try values.decode(Double.self, forKey: .value)

        let unitSpeed: UnitSpeed
        switch unit {
        case .metersPerSecond:
            unitSpeed = .metersPerSecond
        case .knots:
            unitSpeed = .knots
        case .feetPerSecond:
            unitSpeed = .feetPerSecond
        }

        self.underlyingMeasurement = .init(value: value, unit: unitSpeed)
    }
}

public extension UnitSpeed {
    static let feetPerSecond = UnitSpeed(symbol: "ft/s", converter: UnitConverterLinear(coefficient: 1/3.28084))
}
