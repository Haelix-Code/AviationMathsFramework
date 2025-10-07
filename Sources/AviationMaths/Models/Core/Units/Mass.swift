import Foundation

public struct Mass: Equatable {
    fileprivate let underlyingMeasurement: Measurement<UnitMass>

    public init(value: Double, unit: UnitMass) {
        self.underlyingMeasurement = .init(value: value, unit: unit)
    }

    public init(kilograms: Double) {
        self.underlyingMeasurement = .init(value: kilograms, unit: .kilograms)
    }

    public init(pounds: Double) {
        self.underlyingMeasurement = .init(value: pounds, unit: .pounds)
    }

    public var kilograms: Double {
        underlyingMeasurement.converted(to: .kilograms).value
    }

    public var pounds: Double {
        underlyingMeasurement.converted(to: .pounds).value
    }

    public func description(_ unitMass: UnitMass = .kilograms) -> String {
        underlyingMeasurement.converted(to: unitMass).description
    }

}

extension Mass: Encodable {
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

extension Mass: Decodable {
   enum Units: String, Codable {
       case kilograms = "kg"
       case pounds = "lb"
   }

   public init(from decoder: Decoder) throws {
       let values = try decoder.container(keyedBy: CodingKeys.self)
       let unit = try values.decode(Units.self, forKey: .unit)
       let value = try values.decode(Double.self, forKey: .value)

       let unitMass: UnitMass
       switch unit {
       case .kilograms:
           unitMass = .kilograms
       case .pounds:
           unitMass = .pounds
       }

       self.underlyingMeasurement = .init(value: value, unit: unitMass)
   }
}
