import Foundation

public extension Measurement<UnitPressure> {
    var pascals: Double {
        self.converted(to: .newtonsPerMetersSquared).value
    }
    
    var hectopascals: Double {
        self.converted(to: .hectopascals).value
    }
}
