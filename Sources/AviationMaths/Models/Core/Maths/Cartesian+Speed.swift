import Foundation

public extension CartesianVector where UnitType == UnitSpeed {
    var cartesianVectorSpeed: SpeedCartesianVector { self }
    var speed: Measurement<UnitSpeed> { magnitude }
}
