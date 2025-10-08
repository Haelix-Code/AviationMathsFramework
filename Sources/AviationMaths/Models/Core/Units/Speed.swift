import Foundation

public extension UnitSpeed {
    static let feetPerSecond = UnitSpeed(symbol: "ft/s", converter: UnitConverterLinear(coefficient: 1/3.28084))
}
