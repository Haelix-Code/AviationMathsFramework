import Foundation

public extension Measurement<UnitAcceleration> {
    var metersPerSecondSquared: Double {
        self.converted(to: .metersPerSecondSquared).value
    }
}
