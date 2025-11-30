import Foundation

public struct PolarVector<UnitType: Dimension>: Equatable {
    public let angle: Measurement<UnitAngle>        // Radians, math convention
    public let magnitude: Measurement<UnitType>

    public init(angle: Measurement<UnitAngle>, magnitude: Measurement<UnitType>) {
        self.angle = angle
        self.magnitude = magnitude
    }
    
    public var asCartesianVector: CartesianVector<UnitType> {
           let a = angle.converted(to: .radians).value
           let mag = magnitude.value
           return CartesianVector(
               x: Measurement(value: mag * cos(a), unit: magnitude.unit),       // Pure math
               y: Measurement(value: mag * sin(a), unit: magnitude.unit)        // Pure math
           )
       }
}

public typealias LengthPolar = PolarVector<UnitLength>
public typealias SpeedPolar = PolarVector<UnitSpeed>
