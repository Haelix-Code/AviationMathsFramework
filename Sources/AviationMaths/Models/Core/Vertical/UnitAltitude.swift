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
    
    private var seaLevelTemp: Measurement<UnitTemperature> {
        context.seaLevelTemperature ?? ISA.seaLevelTemperature
    }
    
    private var referenceQNH: Measurement<UnitPressure> {
        context.qnh ?? ISA.seaLevelPressure
    }
        
    // MARK: Functions to convert between references
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
        guard let qnh = context.qnh else {
            preconditionFailure("QNH required for PA -> AMSL conversion")
        }
        
        let pressure = BarometricEquations.pressureFromAltitude(
            altitude: value,
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.lapseRate(at: .surface)
        )
        
        return BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: qnh,
            temperature: seaLevelTemp,
            lapseRate: context.lapseRate
        )
        
    }
    
    private func convertTrueAltitudeToAMSL() -> Measurement<UnitLength> {
        let pressure = BarometricEquations.pressureFromTrueAltitude(
            trueAltitude: value,
            referencePressure: referenceQNH,
            referenceTemperature: seaLevelTemp,
            lapseRate: context.lapseRate
        )
        
        return BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: referenceQNH,
            temperature: seaLevelTemp,
            lapseRate: context.lapseRate
        )
    }
    
    private func convertToPressureAltitude() -> Measurement<UnitLength> {
        switch reference {
        case .pressureAltitude:
            return value
            
        case .agl, .amsl:
            return convertAMSLToPressureAltitude()
            
        case .trueAltitude:
            return convertTrueAltitudeToAMSL().asPressureAltitude(context: context)
        }
    }
    
    private func convertAMSLToPressureAltitude() -> Measurement<UnitLength> {
        guard let qnh = context.qnh else {
            preconditionFailure("QNH required for AMSL -> PA conversion")
        }
        
        let amslValue = reference == .agl ? convertToAMSL() : value
        let pressure = BarometricEquations.pressureFromAltitude(
            altitude: amslValue,
            referencePressure: qnh,
            temperature: seaLevelTemp,
            lapseRate: context.lapseRate
            )
        
        return BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.lapseRate(at: .surface))
    }
        
    private func convertToTrueAltitude() -> Measurement<UnitLength> {
        switch reference {
        case .agl, .amsl:
            let amslValue = reference == .agl ? convertToAMSL() : value
            let pressureAtAltitude = BarometricEquations.pressureFromAltitude(altitude: amslValue)
            
            let pressureRatio = pressureAtAltitude.pascals / (context.qnh?.pascals ?? ISA.seaLevelPressure.pascals)
            
            let exponent = (context.lapseRate * ISA.dryAirGasConstant * log(pressureRatio)) / ISA.standardGravity.metersPerSecondSquared
            let trueAltitude = (context.seaLevelTemperature?.kelvin ?? ISA.seaLevelTemperature.kelvin / context.lapseRate) * (1 - exp(exponent))
            
            return .init(meters: trueAltitude)
            
        case .pressureAltitude:
            let amslValue = convertToAMSL()
            let pressureAtAltitude = BarometricEquations.pressureFromAltitude(altitude: amslValue)
            
            let pressureRatio = pressureAtAltitude.pascals / (context.qnh?.pascals ?? ISA.seaLevelPressure.pascals)
            
            let exponent = (context.lapseRate * ISA.dryAirGasConstant * log(pressureRatio)) / ISA.standardGravity.metersPerSecondSquared
            let trueAltitude = (context.seaLevelTemperature?.kelvin ?? ISA.seaLevelTemperature.kelvin / context.lapseRate) * (1 - exp(exponent))
            
            return .init(meters: trueAltitude)
            
        case .trueAltitude:
            return value
        }
    }
        
}

private extension Measurement<UnitLength> {
    func asPressureAltitude(context: AltitudeContext) -> Measurement<UnitLength>{
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
