import Foundation

public extension Measurement<UnitTemperature> {
    var kelvin: Double {
        self.converted(to: .kelvin).value
    }
    
    var celsius: Double {
        self.converted(to: .celsius).value
    }
    
    func convertToDensity(pressure: Measurement<UnitPressure>) -> Measurement<UnitConcentrationMass> {
        let thing: Measurement<UnitConcentrationMass> = .init(value: (pressure.converted(to: .newtonsPerMetersSquared).value / (ISA.dryAirGasConstant * self.kelvin)), unit:.gramsPerLiter)
        return thing
    }
}
