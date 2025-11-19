import Foundation

public struct Vector2D {
    public let x: Measurement<UnitLength>
    public let y: Measurement<UnitLength>

    public init(x: Measurement<UnitLength>, y: Measurement<UnitLength>) {
        self.x = x
        self.y = y
    }

    public init(vectors: [Vector2D]) {
        self.x = .init(meters: vectors.map { $0.x.meters }.reduce(0, +))
        self.y = .init(meters: vectors.map { $0.y.meters }.reduce(0, +))
    }
}

extension Vector2D {
    private var angle: Measurement<UnitAngle> {
        let radians = atan2(y.converted(to: .meters).value,
                               x.converted(to: .meters).value)
        return .init(value: radians, unit: .radians)
    }

    public var length: Measurement<UnitLength> {
        .init(meters: sqrt((pow(x.meters, 2)) + (pow(y.meters, 2))))
    }

    public var polarCoordinate: PolarVector<Measurement<UnitLength>> {
        .init(angle: angle, magnitude: length)
    }

    public func angleBetween(vector2D: Vector2D) -> Measurement<UnitAngle> {
        let numerator = vectorDotProduct(vector1: self, vector2: vector2D).meters
        let length1 = self.length.converted(to: .meters).value
        let length2 = vector2D.length.converted(to: .meters).value
        let ratio = numerator / (length1 * length2)
        let clampedRatio = max(-1.0, min(1.0, ratio))

        return Measurement(value: acos(clampedRatio), unit: .radians)
    }

    private func vectorDotProduct(vector1: Vector2D, vector2: Vector2D) -> Measurement<UnitLength> {
        let x1 = vector1.x.meters
        let x2 = vector2.x.meters
        let y1 = vector1.y.meters
        let y2 = vector2.y.meters
        return .init(meters: x1 * x2 + y1 * y2)
    }
}
