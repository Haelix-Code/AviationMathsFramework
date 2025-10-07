import Foundation

extension Angle {
    public var reciprocal: Angle {
        return .init(radians:(Double.pi + radians).truncatingRemainder(dividingBy: 2 * Double.pi))
    }
    
    public var perpendicularAngles: [Angle] {
        let angle = degrees
        return [.init(degrees: (angle + 90 > 360) ? angle - 270 : angle + 90),
                .init(degrees: (angle - 90 < 0) ? angle + 270 : angle - 90)]
    }
}
