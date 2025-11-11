import Foundation

public extension Measurement<UnitMass> {
    init(kg value: Double) { self.init(value: value, unit: .kilograms) }
    
    init(lbs value: Double) { self.init(value: value, unit: .pounds) }
    
    var kg: Double {
        self.converted(to: .kilograms).value
    }

    var lbs: Double {
        self.converted(to: .pounds).value
    }
}
