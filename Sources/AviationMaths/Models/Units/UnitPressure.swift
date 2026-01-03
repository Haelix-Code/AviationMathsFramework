import Foundation

extension UnitPressure {
    static let pascals = UnitPressure(symbol: "Pa", converter: UnitConverterLinear(coefficient: 1.0))
}

public extension Measurement where UnitType == UnitPressure {
    init(pascals value: Double) { self.init(value: value, unit: .newtonsPerMetersSquared) }

    init(inHg value: Double) { self.init(value: value, unit: .inchesOfMercury) }

    init(hectopascals value: Double) { self.init(value: value, unit: .hectopascals) }

    var pascals: Double {
        self.converted(to: .newtonsPerMetersSquared).value
    }

    var inHg: Double {
        self.converted(to: .inchesOfMercury).value
    }

    var hectopascals: Double {
        self.converted(to: .hectopascals).value
    }
}
