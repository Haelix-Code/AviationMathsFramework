import Foundation

public extension Measurement<UnitTemperature> {

    init(kelvin value: Double) { self.init(value: value, unit: .kelvin) }

    init(celsius value: Double) { self.init(value: value, unit: .celsius) }

    init(fahrenheit value: Double) { self.init(value: value, unit: .fahrenheit) }

    var kelvin: Double {
        self.converted(to: .kelvin).value
    }

    var celsius: Double {
        self.converted(to: .celsius).value
    }

    var fahrenheit: Double {
        self.converted(to: .fahrenheit).value
    }

    func convertToDensity(pressure: Measurement<UnitPressure>) -> Measurement<UnitConcentrationMass> {
        let thing: Measurement<UnitConcentrationMass> = .init(value: (pressure.converted(to: .newtonsPerMetersSquared).value / (ISA.dryAirGasConstant * self.kelvin)), unit: .gramsPerLiter)
        return thing
    }
}
