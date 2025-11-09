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
    
    // MARK: - Convenience Initializers
    
    public init(meters: Double, reference: VerticalReference, context: AltitudeContext) {
        self.init(value: .init(meters: meters), reference: reference, context: context)
    }
    
    public init(feet: Double, reference: VerticalReference, context: AltitudeContext) {
        self.init(value: .init(feet: feet), reference: reference, context: context)
    }
    
    // MARK: - Computed Properties for Each Reference
    
    public var agl: Measurement<UnitLength> {
        reference == .agl ? value : convertToAGL()
    }
    
    public var amsl: Measurement<UnitLength> {
        reference == .amsl ? value : convertToAMSL()
    }
    
    public var pressureAltitude: Measurement<UnitLength> {
        reference == .pressureAltitude ? value : convertToPressureAltitude()
    }
    
    public var trueAltitude: Measurement<UnitLength> {
        reference == .trueAltitude ? value : convertToTrueAltitude()
    }
    
    // MARK: - Private Helpers
    
    private var referenceQNH: Measurement<UnitPressure> {
        context.qnh ?? ISA.seaLevelPressure
    }
    
    private var referenceLapseRate: Double {
        context.lapseRate ?? ISA.troposphereLapseRate
    }
    
    // MARK: - Conversion Methods
    
    private func convertToAGL() -> Measurement<UnitLength> {
        guard let groundElev = context.groundElevation else {
            preconditionFailure("Ground elevation required for AGL conversion")
        }
        
        switch reference {
        case .agl:
            return value
        case .amsl:
            return value - groundElev
        case .pressureAltitude, .trueAltitude:
            return convertToAMSL() - groundElev
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
            return convertPressureAltitudeToAMSL()
            
        case .trueAltitude:
            return convertTrueAltitudeToAMSL()
        }
    }
    
    private func convertPressureAltitudeToAMSL() -> Measurement<UnitLength> {
        // PA → Pressure (using ISA) → AMSL (using actual QNH)
        let pressure = BarometricEquations.pressureFromAltitude(
            altitude: value,
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
        
        return BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: referenceQNH,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
    }
    
    private func convertTrueAltitudeToAMSL() -> Measurement<UnitLength> {
        guard let seaLevelTemp = context.seaLevelTemperature else {
            preconditionFailure("Temperature profile required for True → AMSL conversion")
        }
        
        // True Altitude → Pressure (using actual temp profile) → AMSL (using QNH with ISA)
        let pressure = BarometricEquations.pressureFromTrueAltitude(
            trueAltitude: value,
            referencePressure: referenceQNH,
            referenceTemperature: seaLevelTemp,
            lapseRate: referenceLapseRate
        )
        
        return BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: referenceQNH,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
    }
    
    private func convertToPressureAltitude() -> Measurement<UnitLength> {
        switch reference {
        case .pressureAltitude:
            return value
            
        case .agl, .amsl:
            return convertAMSLToPressureAltitude()
            
        case .trueAltitude:
            // True → AMSL → PA
            return convertTrueAltitudeToAMSL().asPressureAltitude(context: context)
        }
    }
    
    private func convertAMSLToPressureAltitude() -> Measurement<UnitLength> {
        // AMSL → Pressure (using QNH) → PA (using ISA)
        let amslValue = reference == .agl ? convertToAMSL() : value
        
        let pressure = BarometricEquations.pressureFromAltitude(
            altitude: amslValue,
            referencePressure: referenceQNH,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
        
        return BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
    }
    
    private func convertToTrueAltitude() -> Measurement<UnitLength> {
        guard let seaLevelTemp = context.seaLevelTemperature else {
            preconditionFailure("Temperature profile required for True Altitude conversion")
        }
        
        switch reference {
        case .trueAltitude:
            return value
            
        case .agl, .amsl:
            // AMSL → Pressure (using QNH with ISA) → True (using actual temp profile)
            let amslValue = reference == .agl ? convertToAMSL() : value
            
            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: amslValue,
                referencePressure: referenceQNH,
                temperature: ISA.seaLevelTemperature,
                lapseRate: ISA.troposphereLapseRate
            )
            
            return BarometricEquations.trueAltitudeFromPressure(
                pressure: pressure,
                referencePressure: referenceQNH,
                referenceTemperature: seaLevelTemp,
                lapseRate: referenceLapseRate
            )
            
        case .pressureAltitude:
            // PA → Pressure (using ISA) → True (using actual temp profile)
            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: value,
                referencePressure: ISA.seaLevelPressure,
                temperature: ISA.seaLevelTemperature,
                lapseRate: ISA.troposphereLapseRate
            )
            
            return BarometricEquations.trueAltitudeFromPressure(
                pressure: pressure,
                referencePressure: referenceQNH,
                referenceTemperature: seaLevelTemp,
                lapseRate: referenceLapseRate
            )
        }
    }
}

// MARK: - Helper Extension

private extension Measurement<UnitLength> {
    func asPressureAltitude(context: AltitudeContext) -> Measurement<UnitLength> {
        let altitude = Altitude(value: self, reference: .amsl, context: context)
        return altitude.pressureAltitude
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
        case .pressureAltitude: newValue = pressureAltitude
        case .trueAltitude: newValue = trueAltitude
        }
        return Altitude(value: newValue, reference: newReference, context: context)
    }
}

// MARK: - Equatable & Hashable

extension Altitude: Equatable {
    public static func == (lhs: Altitude, rhs: Altitude) -> Bool {
        // Compare in AMSL unless both have ground elevation (then use AGL)
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
