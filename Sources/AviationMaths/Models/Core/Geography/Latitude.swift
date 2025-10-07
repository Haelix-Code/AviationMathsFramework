import Foundation

public struct Latitude: AngularCoordinate {
    public typealias DirectionType = LatitudeDirection
    
    public static let validRange: ClosedRange<Double> = -90.0...90.0
        
    public let decimalDegrees: Double
    
    public var direction: LatitudeDirection {
         LatitudeDirection(decimalDegrees: decimalDegrees)
     }
    
    public init(decimalDegrees: Double) {
       precondition(
           Self.validRange.contains(decimalDegrees),
           "Latitude must be between -90° and +90°, got \(decimalDegrees)°"
       )
       self.decimalDegrees = decimalDegrees
   }
    
    public init(degrees: Double, direction: LatitudeDirection) {
       let value = abs(degrees) * direction.sign
       self.init(decimalDegrees: value)
   }
    
    public init(_ angle: Measurement<UnitAngle>) {
        self.init(decimalDegrees: angle.converted(to: .degrees).value)
    }
    
    public init(dms: DegreesMinutesSeconds, direction: LatitudeDirection) {
       let decimal = dms.asDecimalDegrees
       self.init(degrees: decimal, direction: direction)
   }
    
    public init(ddm: DegreesDecimalMinutes, direction: LatitudeDirection) {
        let decimal = ddm.asDecimalDegrees
        self.init(degrees: decimal, direction: direction)
    }
    
    public init(degrees: Int, minutes: Int, seconds: Double, direction: LatitudeDirection) {
        let dms = DegreesMinutesSeconds(degrees: degrees, minutes: minutes, seconds: seconds)
        self.init(dms: dms, direction: direction)
    }
    
    public init(degrees: Int, minutes: Double, direction: LatitudeDirection) {
        let ddm = DegreesDecimalMinutes(degrees: degrees, minutes: minutes)
        self.init(ddm: ddm, direction: direction)
    }
}
