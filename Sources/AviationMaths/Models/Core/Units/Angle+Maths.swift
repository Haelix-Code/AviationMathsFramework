import Foundation

extension Measurement<UnitAngle> {
    public var reciprocal: Measurement<UnitAngle> {
        return .init(value:((Double.pi + radians).truncatingRemainder(dividingBy: 2 * Double.pi)), unit: .radians)
    }
    
    public var perpendicularAngles: [Measurement<UnitAngle>] {
        let angle = degrees
        return [.init(value: ((angle + 90 > 360) ? angle - 270 : angle + 90), unit: .degrees),
                .init(value: ((angle - 90 < 0) ? angle + 270 : angle - 90), unit: .degrees)]
    }
}
