//import Foundation
//
//public struct Vector2D {
//    public let x: Measurement<UnitLength>
//    public let y: Measurement<UnitLength>
//
//    public init(x: Measurement<UnitLength>, y: Measurement<UnitLength>) {
//        self.x = x
//        self.y = y
//    }
//
//    public init(vectors: [Vector2D]) {
//        self.x = .init(meters: vectors.map { $0.x.meters }.reduce(0, +))
//        self.y = .init(meters: vectors.map { $0.y.meters }.reduce(0, +))
//    }
//}
//
//extension Vector2D {
//    private var angle: Measurement<UnitAngle> {
//        let result: Double
//        let x = x.meters, y = y.meters
//        if x == 0 && y == 0 {
//            result = atan(0)
//        } else if x >= 0 && y >= 0 {
//            result = atan(x / y)
//        } else if x > 0 && y < 0 {
//            result = abs(atan(y / x)) + 0.5 * Double.pi
//        } else if x <= 0 && y < 0 {
//            result = atan(x / y) + Double.pi
//        } else {
//            result = abs(atan(y / x)) + 1.5 * Double.pi
//        }
//        return .init(radians: result)
//    }
//
//    public var length: Measurement<UnitLength> {
//        .init(meters: sqrt((pow(x.meters, 2)) + (pow(y.meters,2))))
//    }
//
//    public var polarCoordinate: PolarVector<Length> {
//        .init(angle: angle, magnitude: length)
//    }
//
//    public func angleBetween(vector2D: Vector2D) -> Measurement<UnitAngle> {
//        let numerator = vectorDotProduct(vector1: self, vector2: vector2D)
//        let denominator = self.length * vector2D.length
//        let ratio = numerator / denominator
//        return .init(radians: acos(ratio.meters))
//    }
//
//    private func vectorDotProduct(vector1: Vector2D, vector2: Vector2D) -> Length {
//        return vector1.x * vector2.x + vector1.y * vector2.y
//    }
//}
