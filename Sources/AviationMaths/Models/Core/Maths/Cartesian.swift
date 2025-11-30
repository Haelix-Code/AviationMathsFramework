import Foundation

public struct CartesianVector<UnitType: Dimension> {
    public let x: Measurement<UnitType>
    public let y: Measurement<UnitType>

    public init(x: Measurement<UnitType>, y: Measurement<UnitType>) {
        self.x = x
        self.y = y
    }

    public init(vectors: [CartesianVector<UnitType>]) {
            self.x = Measurement(value: vectors.map { $0.x.value }.reduce(0, +),
                                 unit: vectors.first?.x.unit ?? UnitType.baseUnit())
            self.y = Measurement(value: vectors.map { $0.y.value }.reduce(0, +),
                                 unit: vectors.first?.y.unit ?? UnitType.baseUnit())
        }
}

extension CartesianVector {
    public var asPolar: PolarVector<UnitType> {
        PolarVector(angle: angle, magnitude: magnitude)
    }
    
    public var magnitude: Measurement<UnitType> {
           let xVal = x.converted(to: x.unit).value
           let yVal = y.converted(to: y.unit).value
           let mag = sqrt(xVal * xVal + yVal * yVal)
           return Measurement(value: mag, unit: x.unit)
       }
    
    public var angle: Measurement<UnitAngle> {
        let xVal = x.value
        let yVal = y.value
        return Measurement(value: atan2(yVal, xVal), unit: .radians)
    }

    public func angle(between other: CartesianVector<UnitType>) -> Measurement<UnitAngle> {
        let d = dot(other).value
        let m1 = magnitude.value
        let m2 = other.magnitude.value
        let ratio = max(-1, min(1, d / (m1 * m2)))
        return Measurement(value: acos(ratio), unit: .radians)
    }
}

public typealias LengthCartesianVector = CartesianVector<UnitLength>
public typealias SpeedCartesianVector    = CartesianVector<UnitSpeed>
