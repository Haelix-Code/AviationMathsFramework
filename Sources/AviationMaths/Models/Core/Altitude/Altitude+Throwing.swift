import Foundation

extension Altitude {
    
    // MARK: - Throwing Public Conversion Methods
    
    /// Returns altitude in the specified reference frame, throwing an error if conversion fails
    /// - Parameter newReference: The target altitude reference
    /// - Throws: `AltitudeConversionError` if context lacks required data for conversion
    /// - Returns: Altitude value in the specified reference
    public func valueThrowing(in ref: VerticalReference) throws -> Measurement<UnitLength> {
        switch ref {
        case .agl: return try convertToAGLThrowing()
        case .amsl: return try convertToAMSLThrowing()
        case .pressureAltitude: return try convertToPressureAltitudeThrowing()
        case .trueAltitude: return try convertToTrueAltitudeThrowing()
        case .geopotential: return try convertToGeopotentialThrowing()
        }
    }
    
    /// Creates a new Altitude in the specified reference frame, throwing an error if conversion fails
    /// - Parameter newReference: The target altitude reference
    /// - Throws: `AltitudeConversionError` if context lacks required data for conversion
    /// - Returns: Altitude in the new reference frame
    public func convertedThrowing(to newReference: VerticalReference) throws -> Altitude {
        let newValue = try valueThrowing(in: newReference)
        return Altitude(value: newValue, reference: newReference, context: context)
    }
    
    // MARK: - Internal Throwing Conversion Methods
    
    internal func convertToAGLThrowing() throws -> Measurement<UnitLength> {
        switch reference {
        case .agl:
            return value

        case .amsl:
            guard let elevation = context.groundElevation else {
                throw AltitudeConversionError.missingGroundElevation
            }
            return .init(meters: value.meters - elevation.meters)

        case .pressureAltitude:
            let amsl = try convertToAMSLThrowing()
            guard let elevation = context.groundElevation else {
                throw AltitudeConversionError.missingGroundElevation
            }
            return .init(meters: amsl.meters - elevation.meters)

        case .trueAltitude:
            let amsl = try convertTrueAltitudeToAMSLThrowing()
            guard let elevation = context.groundElevation else {
                throw AltitudeConversionError.missingGroundElevation
            }
            return .init(meters: amsl.meters - elevation.meters)

        case .geopotential:
            // Geopotential → True (pure geometric) → AGL
            let trueAlt = convertGeopotentialToTrueAltitude()
            guard let elevation = context.groundElevation else {
                throw AltitudeConversionError.missingGroundElevation
            }
            return .init(meters: trueAlt.meters - elevation.meters)
        }
    }
    
    internal func convertToAMSLThrowing() throws -> Measurement<UnitLength> {
        switch reference {
        case .agl:
            guard let elevation = context.groundElevation else {
                throw AltitudeConversionError.missingGroundElevation
            }
            return .init(meters: value.meters + elevation.meters)

        case .amsl:
            return value

        case .pressureAltitude:
            return try convertPressureAltitudeToAMSLThrowing()

        case .trueAltitude:
            return try convertTrueAltitudeToAMSLThrowing()

        case .geopotential:
            // Geopotential → True (pure geometric) → AMSL
            let trueAlt = convertGeopotentialToTrueAltitude()
            return try Altitude(value: trueAlt, reference: .trueAltitude, context: context)
                .convertToAMSLThrowing()
        }
    }
    
    internal func convertToPressureAltitudeThrowing() throws -> Measurement<UnitLength> {
        switch reference {
        case .pressureAltitude:
            return value

        case .agl, .amsl:
            return try convertAMSLToPressureAltitudeThrowing()

        case .trueAltitude:
            let amsl = try convertTrueAltitudeToAMSLThrowing()
            return try Altitude(value: amsl, reference: .amsl, context: context)
                .convertToPressureAltitudeThrowing()

        case .geopotential:
            // Geopotential → True (pure geometric) → PA
            let trueAlt = convertGeopotentialToTrueAltitude()
            return try Altitude(value: trueAlt, reference: .trueAltitude, context: context)
                .convertToPressureAltitudeThrowing()
        }
    }
    
    internal func convertToTrueAltitudeThrowing() throws -> Measurement<UnitLength> {
        switch reference {
        case .trueAltitude:
            return value

        case .geopotential:
            // Geopotential → True is a pure geometric transformation
            return convertGeopotentialToTrueAltitude()

        case .agl, .amsl:
            guard let seaLevelTemp = context.seaLevelTemperature else {
                throw AltitudeConversionError.missingTemperatureProfile
            }

            guard let lapseRate = context.lapseRate else {
                throw AltitudeConversionError.missingTemperatureProfile
            }

            let amslValue = reference == .agl ? try convertToAMSLThrowing() : value

            guard let qnh = context.qnh else {
                throw AltitudeConversionError.missingQNH
            }

            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: amslValue,
                referencePressure: qnh,
                temperature: ISA.seaLevelTemperature,
                lapseRate: ISA.troposphereLapseRate
            )

            return BarometricEquations.trueAltitudeFromPressure(
                pressure: pressure,
                referencePressure: qnh,
                referenceTemperature: seaLevelTemp,
                lapseRate: lapseRate
            )

        case .pressureAltitude:
            guard let seaLevelTemp = context.seaLevelTemperature else {
                throw AltitudeConversionError.missingTemperatureProfile
            }

            guard let lapseRate = context.lapseRate else {
                throw AltitudeConversionError.missingTemperatureProfile
            }

            let pressure = BarometricEquations.pressureFromAltitude(
                altitude: value,
                referencePressure: ISA.seaLevelPressure,
                temperature: ISA.seaLevelTemperature,
                lapseRate: ISA.troposphereLapseRate
            )

            guard let qnh = context.qnh else {
                throw AltitudeConversionError.missingQNH
            }

            return BarometricEquations.trueAltitudeFromPressure(
                pressure: pressure,
                referencePressure: qnh,
                referenceTemperature: seaLevelTemp,
                lapseRate: lapseRate
            )
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func convertPressureAltitudeToAMSLThrowing() throws -> Measurement<UnitLength> {
        guard let qnh = context.qnh else {
            throw AltitudeConversionError.missingQNH
        }
        
        let pressure = BarometricEquations.pressureFromAltitude(
            altitude: value,
            referencePressure: ISA.seaLevelPressure,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
        
        return BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: qnh,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
    }
    
    private func convertAMSLToPressureAltitudeThrowing() throws -> Measurement<UnitLength> {
        let amslValue = reference == .agl ? try convertToAMSLThrowing() : value
        
        guard let qnh = context.qnh else {
            throw AltitudeConversionError.missingQNH
        }
        
        let pressure = BarometricEquations.pressureFromAltitude(
            altitude: amslValue,
            referencePressure: qnh,
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
    
    private func convertTrueAltitudeToAMSLThrowing() throws -> Measurement<UnitLength> {
        guard let seaLevelTemp = context.seaLevelTemperature else {
            throw AltitudeConversionError.missingTemperatureProfile
        }

        guard let lapseRate = context.lapseRate else {
            throw AltitudeConversionError.missingTemperatureProfile
        }

        guard let qnh = context.qnh else {
            throw AltitudeConversionError.missingQNH
        }

        let pressure = BarometricEquations.pressureFromTrueAltitude(
            trueAltitude: value,
            referencePressure: qnh,
            referenceTemperature: seaLevelTemp,
            lapseRate: lapseRate
        )

        return BarometricEquations.altitudeFromPressure(
            pressure: pressure,
            referencePressure: qnh,
            temperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
    }

    // MARK: - Geopotential Conversion

    /// Convert to geopotential altitude
    /// Geopotential requires true altitude, which requires a temperature profile
    internal func convertToGeopotentialThrowing() throws -> Measurement<UnitLength> {
        switch reference {
        case .geopotential:
            return value

        case .trueAltitude:
            // True → Geopotential is a pure geometric transformation
            let r = ISA.earthMeanRadius.meters
            let h = value.meters
            let H = (r * h) / (r + h)
            return .init(meters: H)

        case .agl, .amsl, .pressureAltitude:
            // First convert to true altitude, then to geopotential
            let trueAlt = try convertToTrueAltitudeThrowing()
            let r = ISA.earthMeanRadius.meters
            let h = trueAlt.meters
            let H = (r * h) / (r + h)
            return .init(meters: H)
        }
    }
}
