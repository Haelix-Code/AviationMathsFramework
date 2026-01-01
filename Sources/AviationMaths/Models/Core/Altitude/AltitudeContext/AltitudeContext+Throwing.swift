import Foundation

extension AltitudeContext {
    
    // MARK: - Throwing Methods for Context Properties
    
    /// Returns surface temperature, throwing an error if it cannot be calculated
    /// - Throws: `ContextCalculationError.insufficientData` if required data is missing
    /// - Returns: Surface temperature
    public func surfaceTemperatureThrowing() throws -> Measurement<UnitTemperature> {
        if let explicitTemp = _surfaceTemperature {
            return explicitTemp
        }

        guard let seaLevelTemp = _seaLevelTemperature,
              let elevation = groundElevation,
              let lapse = lapseRate else {
            throw ContextCalculationError.insufficientData(
                calculation: "surfaceTemperature",
                missing: missingForSurfaceTemp()
            )
        }

        let surfaceTempKelvin = seaLevelTemp.kelvin - (lapse * elevation.meters)
        return .init(kelvin: surfaceTempKelvin)
    }
    
    /// Returns sea level temperature, throwing an error if it cannot be calculated
    /// - Throws: `ContextCalculationError.insufficientData` if required data is missing
    /// - Returns: Sea level temperature
    public func seaLevelTemperatureThrowing() throws -> Measurement<UnitTemperature> {
        if let explicitTemp = _seaLevelTemperature {
            return explicitTemp
        }

        guard let surfaceTemp = _surfaceTemperature,
              let elevation = groundElevation,
              let lapse = lapseRate else {
            throw ContextCalculationError.insufficientData(
                calculation: "seaLevelTemperature",
                missing: missingForSeaLevelTemp()
            )
        }

        let seaLevelTempKelvin = surfaceTemp.kelvin + (lapse * elevation.meters)
        return .init(kelvin: seaLevelTempKelvin)
    }
    
    // MARK: - Private Helpers
    
    private func missingForSurfaceTemp() -> [String] {
        var missing: [String] = []
        if _seaLevelTemperature == nil { missing.append("seaLevelTemperature") }
        if groundElevation == nil { missing.append("groundElevation") }
        if lapseRate == nil { missing.append("lapseRate") }
        return missing
    }
    
    private func missingForSeaLevelTemp() -> [String] {
        var missing: [String] = []
        if _surfaceTemperature == nil { missing.append("surfaceTemperature") }
        if groundElevation == nil { missing.append("groundElevation") }
        if lapseRate == nil { missing.append("lapseRate") }
        return missing
    }
}
