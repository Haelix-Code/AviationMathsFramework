import Foundation

public struct Pressure: Equatable, Codable, Sendable {
    fileprivate let underlyingMeasurement: Measurement<UnitPressure>

    public init(value: Double, unit: UnitPressure) {
        self.underlyingMeasurement = .init(value: value, unit: unit)
    }

    public init(pascals: Double) {
        self.underlyingMeasurement = .init(value: pascals, unit: .newtonsPerMetersSquared)
    }

    public init(_ measurement: Measurement<UnitPressure>) {
        self.underlyingMeasurement = measurement
    }

    public var hectopascals: Double {
        underlyingMeasurement.converted(to: .hectopascals).value
    }

    public var pascals: Double {
        underlyingMeasurement.converted(to: .newtonsPerMetersSquared).value
    }

    public var inchesOfMercury: Double {
        underlyingMeasurement.converted(to: .inchesOfMercury).value
    }
}

public extension Measurement<UnitPressure> {
    var pascals: Double {
        self.converted(to: .newtonsPerMetersSquared).value
    }
}
