import Foundation

extension PolarVector where UnitType == UnitSpeed {
    public var speed: Measurement<UnitSpeed> { magnitude }

    public var reciprocalBearing: Measurement<UnitAngle> {
        Measurement(value: bearing.degrees + 180, unit: .degrees).normalized
    }
}
