import Foundation

public extension UnitSpeed {
    static let feetPerSecond = UnitSpeed(symbol: "ft/s", converter: UnitConverterLinear(coefficient: 1/3.28084))
}

public extension Measurement<UnitSpeed>{
    init(mps value: Double) { self.init(value: value, unit: .metersPerSecond) }
    
    init(knots value: Double) { self.init(value: value, unit: .knots) }
    
    init(fps value: Double) { self.init(value: value, unit: .feetPerSecond) }
    
    var mps: Double {
        self.converted(to: .metersPerSecond).value
    }
    
    var knots: Double {
        self.converted(to: .knots).value
    }
    
    var fps: Double {
        self.converted(to: .feetPerSecond).value
    }
}
