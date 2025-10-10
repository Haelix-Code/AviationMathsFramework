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
        guard let groundElev = context.groundElevation else {
            preconditionFailure("Ground elevation required for AMSL conversion")
        }
        return .init(meters: agl.meters + groundElev.meters)
    }
    
    public var pa: Measurement<UnitLength> {
        if reference == .pressureAltitude {
            return value
        }
        guard let groundElev = context.groundElevation,
              let qnh = context.qnh else {
            preconditionFailure("Ground elevation and QNH required for pressure altitude conversion")
        }
        
        let aglMeters = agl.meters
        let amslMeters = aglMeters + groundElev.meters
        
        let pressureAtAMSL = BarometricEquations.pressureFromAltitude(
            altitude: .init(meters: amslMeters),
            referencePressure: qnh
        )
        
        let paMeters = BarometricEquations.altitudeFromPressure(
            pressure: pressureAtAMSL
        )
        
        return paMeters
    }
    
    /// Get this altitude as True Altitude (corrected for temperature)
    public var trueAltitude: Measurement<UnitLength> {
        if reference == .trueAltitude {
            return value
        }
        guard let groundElev = context.groundElevation,
              let qnh = context.qnh,
              let surfaceTemp = context.surfaceTemperature else {
            preconditionFailure("Ground elevation, QNH, and surface temperature required for true altitude conversion")
        }
        
        let aglMeters = agl.meters
        let dropAltitudeAMSL = aglMeters + groundElev.meters
        
        let seaLevelTemperatureK = surfaceTemp.kelvin - (context.lapseRate * groundElev.meters)
        
        let pressureAtDropAltitude = BarometricEquations.pressureFromAltitude(
            altitude: .init(meters: dropAltitudeAMSL),
            referencePressure: qnh,
            temperature: .init(kelvin: seaLevelTemperatureK),
            lapseRate: context.lapseRate
        )
        
        let trueAltMeters = BarometricEquations.altitudeFromPressure(
            pressure: pressureAtDropAltitude,

        )
        
        return trueAltMeters
    }

    private func convertToAGL() -> Measurement<UnitLength> {
        switch reference {
        case .agl:
            return value
            
        case .amsl:
            guard let groundElev = context.groundElevation else {
                preconditionFailure("Ground elevation required for AMSL to AGL conversion")
            }
            return .init(meters: value.meters - groundElev.meters)
            
        case .pressureAltitude:
            guard let groundElev = context.groundElevation,
                  let qnh = context.qnh else {
                preconditionFailure("Ground elevation and QNH required for PA to AGL conversion")
            }
            
            // PA -> pressure using standard pressure
            let pressureAtPA = BarometricEquations.pressureFromAltitude(
                altitude: value,
                referencePressure: ISA.seaLevelPressure
            )
            
            // Pressure -> AMSL altitude (using QNH)
            let amslMeters = BarometricEquations.altitudeFromPressure(
                pressure: pressureAtPA,
                referencePressure: qnh
            )
            
            // AMSL -> AGL
            return amslMeters - groundElev
            
        case .trueAltitude:
            guard let groundElev = context.groundElevation,
                  let qnh = context.qnh,
                  let surfaceTemp = context.surfaceTemperature else {
                preconditionFailure("Ground elevation, QNH, and surface temperature required for TA to AGL conversion")
            }
            
            // Calculate sea level temperature
            let seaLevelTemperatureK = surfaceTemp.kelvin - (context.lapseRate * groundElev.meters)
            
            // True altitude -> pressure
            let pressureAtTrueAltitude = BarometricEquations.pressureFromAltitude(
                altitude: value,
                referencePressure: qnh,
                temperature: .init(kelvin: seaLevelTemperatureK),
                lapseRate: context.lapseRate
            )
            
            // Pressure -> AMSL
            let dropAltitudeAMSL = BarometricEquations.altitudeFromPressure(
                pressure: pressureAtTrueAltitude,
                referencePressure: qnh,
                temperature: .init(kelvin: seaLevelTemperatureK),
                lapseRate: context.lapseRate
            )
            
            // AMSL -> AGL
            return dropAltitudeAMSL - groundElev

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
        case .trueAltitude: newValue = trueAltitude
        }
        return Altitude(value: newValue, reference: newReference, context: context)
    }
}

// MARK: - Equatable & Hashable

extension Altitude: Equatable {
    public static func == (lhs: Altitude, rhs: Altitude) -> Bool {
        // Two altitudes are equal if they represent the same physical height
        // regardless of reference frame
        lhs.agl.meters == rhs.agl.meters
    }
}

extension Altitude: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(agl.meters)
    }
}

// MARK: - Comparable

extension Altitude: Comparable {
    public static func < (lhs: Altitude, rhs: Altitude) -> Bool {
        lhs.agl.meters < rhs.agl.meters
    }
}

