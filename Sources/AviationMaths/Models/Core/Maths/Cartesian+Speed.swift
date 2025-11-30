import Foundation

public extension CartesianVector where UnitType == UnitSpeed {
    var cartesianVectorSpeed: CartesianVector<UnitSpeed> { self }
    var speed: Measurement<UnitSpeed> { magnitude }
}
