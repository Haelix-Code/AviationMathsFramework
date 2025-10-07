import Foundation

public struct Temperature: Equatable, Sendable {
    fileprivate let underlyingMeasurement: Measurement<UnitTemperature>

    public init(_ measurement: Measurement<UnitTemperature>) {
        self.underlyingMeasurement = measurement
    }

    public init(value: Double, unit: UnitTemperature) {
        self.underlyingMeasurement = .init(value: value, unit: unit)
    }

    public init(celsius: Double) {
        self.underlyingMeasurement = .init(value: celsius, unit: .celsius)
    }

    public var kelvin: Double {
        underlyingMeasurement.converted(to: .kelvin).value
    }

    public var celsius: Double {
        underlyingMeasurement.converted(to: .celsius).value
    }

    public func description(_ unitTemperature: UnitTemperature = .celsius) -> String {
        underlyingMeasurement.converted(to: unitTemperature).description
    }
}

public extension Measurement<UnitTemperature> {
    var kelvin: Double {
        self.converted(to: .kelvin).value
    }
    var celsius: Double {
        self.converted(to: .celsius).value
    }
}


extension Temperature: Encodable {
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

extension Temperature: Decodable {
    enum Units: String, Codable {
        case celcius = "°C"
        case kelvin = "K"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let unit = try values.decode(Units.self, forKey: .unit)
        let value = try values.decode(Double.self, forKey: .value)

        let unitTemperature: UnitTemperature
        switch unit {
        case .celcius:
            unitTemperature = .celsius
        case .kelvin:
            unitTemperature = .kelvin
        }

        self.underlyingMeasurement = .init(value: value, unit: unitTemperature)
    }
}

public extension Measurement<UnitTemperature> {
    func convertToDensity(pressure: Measurement<UnitPressure>) -> Measurement<UnitConcentrationMass> {
        let thing: Measurement<UnitConcentrationMass> = .init(value: (pressure.converted(to: .newtonsPerMetersSquared).value / (ISA.dryAirGasConstant * self.kelvin)), unit:.gramsPerLiter)
        return thing
    }
}
