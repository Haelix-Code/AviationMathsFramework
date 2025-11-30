import Foundation

extension PolarVector where UnitType == UnitSpeed {
    
    static func fromBearing(degrees: Double, speed: Measurement<UnitSpeed>, fromDirection: Bool = true) -> PolarVector<UnitSpeed> {
        // Aviation: 0 = North, clockwise, "from" means vector points opposite
        var angleRad = (90 - degrees) * .pi / 180
        if fromDirection { angleRad += .pi } // from → toward
        return PolarVector(angle: .init(value: angleRad, unit: .radians), magnitude: speed)
    }
    
    var bearing: Double {
        // Convert counterclockwise math angle to aviation bearing
        var deg = 90 - angle.converted(to: .radians).value * 180 / .pi
        deg = deg.truncatingRemainder(dividingBy: 360)
        if deg < 0 { deg += 360 }
        return deg
    }
    
    var fromBearing: Double {
        (bearing + 180).truncatingRemainder(dividingBy: 360)
    }
}
