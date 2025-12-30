import Foundation

public extension Measurement where UnitType == UnitLength {
    init(feet value: Double) { self.init(value: value, unit: .feet) }

    init(meters value: Double) { self.init(value: value, unit: .meters) }

    init(nauticalMiles value: Double) { self.init(value: value, unit: .nauticalMiles)}

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

public extension Measurement where UnitType == UnitLength {
    static var surface: Measurement<UnitLength> {
        self.init(value: 0, unit: .meters)
    }
}
