import Foundation

public struct Altitude: Sendable {
    public let value: Measurement<UnitLength>
    public let reference: VerticalReference
    public let context: AltitudeContext
    
    public init(value: Measurement<UnitLength>, reference: VerticalReference, context: AltitudeContext) {
        self.value = value
        self.reference = reference
        self.context = context
    }
    
    // Convenience initializers
    public init(meters: Double, reference: VerticalReference, context: AltitudeContext) {
        self.init(value: .init(meters: meters), reference: reference, context: context)
    }
    
    public init(feet: Double, reference: VerticalReference, context: AltitudeContext) {
        self.init(value: .init(feet: feet), reference: reference, context: context)
    }
    
    
    public var agl: Measurement<UnitLength> {
        if reference == .agl {
            return value
        }
        return convertToAGL()
    }
    
    public var amsl: Measurement<UnitLength> {
        if reference == .amsl {
            return value
        }
        return convertToAMSL()
    }
    
    public var pa: Measurement<UnitLength> {
        if reference == .pressureAltitude {
            return value
        }
        return convertToPA()
    }
    
    public var densityAltitude: Measurement<UnitLength> {
        if reference == .densityAltitude {
            return value
        }
        return convertToDensityAltitude()
    }
    
    
    private func convertToAGL() -> Measurement<UnitLength> {
        guard let groundElev = context.groundElevation else {
            preconditionFailure("Ground elevation required for AGL conversion")
        }
        
        switch reference {
        case .agl:
            return value
            
        case .amsl:
            return value - groundElev
            
        case .pressureAltitude:
            // PA → AMSL → AGL
            let amslValue = convertToAMSL()
            return amslValue - groundElev
            
        case .densityAltitude:
            // DA → AMSL → AGL
            let amslValue = convertToAMSL()
            return amslValue - groundElev
        }
    }
    
    private func convertToAMSL() -> Measurement<UnitLength> {
        switch reference {
        case .agl:
            guard let groundElev = context.groundElevation else {
                preconditionFailure("Ground elevation required for AGL → AMSL conversion")
            }
            return value + groundElev
            
        case .amsl:
            return value
            
        case .pressureAltitude:
            // PA → AMSL: Standard atmosphere pressure → actual atmosphere altitude
            guard let qnh = context.qnh else {
                preconditionFailure("QNH required for PA → AMSL conversion")
            }
            
            // Pressure at this PA in standard atmosphere
            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: value,
                referencePressure: ISA.seaLevelPressure,
                temperature: ISA.seaLevelTemperature,
                lapseRate: ISA.lapseRate(at: .surface)
            )
            
            // Altitude in actual atmosphere (with QNH) that has this pressure
            let seaLevelTemp = context.seaLevelTemperature ?? ISA.seaLevelTemperature
            return BarometricEquations.altitudeFromPressure(
                pressure: pressure,
                referencePressure: qnh,
                temperature: seaLevelTemp,
                lapseRate: context.lapseRate
            )
            
        case .densityAltitude:
            // DA → AMSL: Temperature-corrected altitude → actual altitude
            guard let qnh = context.qnh else {
                preconditionFailure("QNH required for Density Altitude → AMSL conversion")
            }
            
            let seaLevelTemp = context.seaLevelTemperature ?? ISA.seaLevelTemperature
            
            // Pressure at this true altitude
            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: value,
                referencePressure: ISA.seaLevelPressure,
                temperature: seaLevelTemp,
                lapseRate: context.lapseRate
            )
            
            // AMSL altitude with actual QNH that has this pressure
            return BarometricEquations.altitudeFromPressure(
                pressure: pressure,
                referencePressure: qnh,
                temperature: seaLevelTemp,
                lapseRate: context.lapseRate
            )
        }
    }
    
    private func convertToPA() -> Measurement<UnitLength> {
        switch reference {
        case .agl, .amsl:
            // AGL/AMSL → AMSL → PA
            guard let qnh = context.qnh else {
                preconditionFailure("QNH required for AMSL → PA conversion")
            }
            
            let amslValue = reference == .agl ? convertToAMSL() : value
            let seaLevelTemp = context.seaLevelTemperature ?? ISA.seaLevelTemperature
            
            // Pressure at this AMSL altitude (actual atmosphere)
            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: amslValue,
                referencePressure: qnh,
                temperature: seaLevelTemp,
                lapseRate: context.lapseRate
            )
            
            // Altitude in standard atmosphere with this pressure
            return BarometricEquations.altitudeFromPressure(
                pressure: pressure,
                referencePressure: ISA.seaLevelPressure,
                temperature: ISA.seaLevelTemperature,
                lapseRate: ISA.lapseRate(at: .surface)
            )
            
        case .pressureAltitude:
            return value
            
        case .densityAltitude:
            // TA → PA: Both are altitude readings, just with different temperature models
            // TA uses actual temperature, PA uses standard temperature
            let seaLevelTemp = context.seaLevelTemperature ?? ISA.seaLevelTemperature
            
            // Pressure at this density altitude (using actual temperature)
            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: value,
                referencePressure: ISA.seaLevelPressure,
                temperature: seaLevelTemp,
                lapseRate: context.lapseRate
            )
            
            // Altitude in standard atmosphere with this pressure
            return BarometricEquations.altitudeFromPressure(
                pressure: pressure,
                referencePressure: ISA.seaLevelPressure,
                temperature: ISA.seaLevelTemperature,
                lapseRate: ISA.lapseRate(at: .surface)
            )
        }
    }
    
    private func convertToDensityAltitude() -> Measurement<UnitLength> {
        // Density altitude requires temperature information
        guard context.temperatureAtReference != nil else {
            preconditionFailure("Temperature information required for Density Altitude conversion")
        }
        
        let seaLevelTemp = context.seaLevelTemperature ?? ISA.seaLevelTemperature
        
        switch reference {
        case .agl, .amsl:
            // AMSL → TA: Apply temperature correction
            let amslValue = reference == .agl ? convertToAMSL() : value
            
            // Pressure at this AMSL altitude (using actual temperature)
            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: amslValue,
                referencePressure: context.qnh ?? ISA.seaLevelPressure,
                temperature: seaLevelTemp,
                lapseRate: context.lapseRate
            )
            
            // True altitude in standard pressure (with actual temperature)
            return BarometricEquations.altitudeFromPressure(
                pressure: pressure,
                referencePressure: ISA.seaLevelPressure,
                temperature: seaLevelTemp,
                lapseRate: context.lapseRate
            )
            
        case .pressureAltitude:
            // PA → TA: Standard temperature → actual temperature
            // Pressure at this PA (standard atmosphere)
            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: value,
                referencePressure: ISA.seaLevelPressure,
                temperature: ISA.seaLevelTemperature,
                lapseRate: ISA.lapseRate(at: .surface)
            )
            
            // Altitude with actual temperature that has this pressure
            return BarometricEquations.altitudeFromPressure(
                pressure: pressure,
                referencePressure: ISA.seaLevelPressure,
                temperature: seaLevelTemp,
                lapseRate: context.lapseRate
            )
            
        case .densityAltitude:
            return value
        }
    }
}

// MARK: - Convenience Properties

extension Altitude {
    /// Create a new Altitude in a different reference frame
    public func `in`(_ newReference: VerticalReference) -> Altitude {
        let newValue: Measurement<UnitLength>
        switch newReference {
        case .agl: newValue = agl
        case .amsl: newValue = amsl
        case .pressureAltitude: newValue = pa
        case .densityAltitude: newValue = densityAltitude
        }
        return Altitude(value: newValue, reference: newReference, context: context)
    }
}

// MARK: - Equatable & Hashable

extension Altitude: Equatable {
    public static func == (lhs: Altitude, rhs: Altitude) -> Bool {
        if lhs.context.groundElevation != nil && rhs.context.groundElevation != nil {
            return lhs.agl.meters == rhs.agl.meters
        } else {
            return lhs.amsl.meters == rhs.amsl.meters
        }
    }
}

extension Altitude: Hashable {
    public func hash(into hasher: inout Hasher) {
        if context.groundElevation != nil {
            hasher.combine(agl.meters)
        } else {
            hasher.combine(amsl.meters)
        }
    }
}

// MARK: - Comparable

extension Altitude: Comparable {
    public static func < (lhs: Altitude, rhs: Altitude) -> Bool {
        if lhs.context.groundElevation != nil && rhs.context.groundElevation != nil {
            return lhs.agl.meters < rhs.agl.meters
        } else {
            return lhs.amsl.meters < rhs.amsl.meters
        }
    }
}
