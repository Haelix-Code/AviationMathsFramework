import Foundation

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
