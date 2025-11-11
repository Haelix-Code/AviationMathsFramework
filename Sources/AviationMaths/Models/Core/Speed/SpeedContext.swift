import Foundation

public struct SpeedContext: Sendable {
    public let pressureAltitude: Measurement<UnitLength>?
    public let temperature: Measurement<UnitTemperature>?
    public let deltaISA: Measurement<UnitTemperature>?
    
    private let _density: Measurement<UnitConcentrationMass>?
    
    public var density: Measurement<UnitConcentrationMass>? {
        if let density = _density {
            return density
        }
        
        guard let altitude = pressureAltitude else { return nil }
        let delta = deltaISA ?? .init(kelvin: 0)
        return ISA.density(at: altitude, deltaISA: delta)
    }
    
    public var speedOfSound: Measurement<UnitSpeed>? {
        guard let altitude = pressureAltitude else { return nil }
        let delta = deltaISA ?? .init(kelvin: 0)
        return ISA.speedOfSound(at: altitude, deltaISA: delta)
    }
    
    public var relativePressure: Double? {
        guard let altitude = pressureAltitude else { return nil }
        let delta = deltaISA ?? .init(kelvin: 0)
        let pressure = ISA.pressure(at: altitude, deltaISA: delta)
        return pressure.pascals / ISA.seaLevelPressure.pascals
    }
    
    public init(
        pressureAltitude: Measurement<UnitLength>? = nil,
        temperature: Measurement<UnitTemperature>? = nil,
        deltaISA: Measurement<UnitTemperature>? = nil,
        density: Measurement<UnitConcentrationMass>? = nil
    ) {
        self.pressureAltitude = pressureAltitude
        self.temperature = temperature
        self.deltaISA = deltaISA
        self._density = density
    }
    
    public static let standardISA = SpeedContext(
        pressureAltitude: .surface,
        temperature: ISA.seaLevelTemperature,
        deltaISA: .init(kelvin: 0),
        density: ISA.seaLevelDensity
    )
}
