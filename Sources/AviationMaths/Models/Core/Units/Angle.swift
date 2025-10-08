import Foundation

public extension Measurement<UnitAngle> {
    init(degrees value: Double) { self.init(value: value, unit: .degrees) }
    
    init(radians value: Double) { self.init(value: value, unit: .radians) }
    
    var degrees: Double {
        self.converted(to: .degrees).value
    }
    
    var radians: Double {
        self.converted(to: .radians).value
    }
}
