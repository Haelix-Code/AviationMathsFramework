import Foundation

extension RelativePosition {
    public init<C: Collection>(summing positions: C) where C.Element == RelativePosition {
        let vectors = positions.map { $0.cartesianVector }
        let resultVector = CartesianVector.sum(vectors)
        self.init(cartesianVector: resultVector)
    }

    public init?<C: Collection>(averaging positions: C) where C.Element == RelativePosition {
        guard !positions.isEmpty else { return nil }

        let sum = RelativePosition(summing: positions)
        let count = Double(positions.count)
        self = sum / count
    }
}

extension Collection where Element == RelativePosition {
    public func sum() -> RelativePosition {
        RelativePosition(summing: self)
    }

    public func average() -> RelativePosition? {
        RelativePosition(averaging: self)
    }
}
extension Sequence where Element == RelativePosition {
    public func sum() -> RelativePosition {
        let vectors = self.map { $0.cartesianVector }
        let resultVector = CartesianVector.sum(vectors)
        return RelativePosition(cartesianVector: resultVector)
    }
}
