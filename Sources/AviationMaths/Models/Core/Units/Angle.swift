import Foundation

public extension Measurement<UnitAngle> {
    var degrees: Double {
        self.converted(to: .degrees).value
    }
    
    var radians: Double {
        self.converted(to: .radians).value
    }
}
