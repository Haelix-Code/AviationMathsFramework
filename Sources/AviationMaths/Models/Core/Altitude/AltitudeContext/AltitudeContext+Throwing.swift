import Foundation

extension AltitudeContext {

    // MARK: - Temperatures

    /// Surface temperature (at ground elevation): the one given, or the sea-level temperature
    /// carried up to ground elevation at the lapse rate. Use `try?` for an optional result.
    /// - Throws: `AltitudeConversionError.missingGroundElevation` if only the ground elevation is
    ///   missing, otherwise `.missingTemperatureProfile`.
    public var surfaceTemperature: Measurement<UnitTemperature> {
        get throws(AltitudeConversionError) {
            if let explicitTemp = _surfaceTemperature {
                return explicitTemp
            }

            guard let seaLevelTemp = _seaLevelTemperature,
                  let elevation = groundElevation,
                  let lapse = lapseRate else {
                throw missingDataToMove(_seaLevelTemperature)
            }

            let surfaceTempKelvin = seaLevelTemp.kelvin - (lapse * elevation.meters)
            return .init(kelvin: surfaceTempKelvin)
        }
    }

    /// Sea level temperature (at height = 0). When a surface temperature is also given,
    /// and it can be extrapolated down, it takes precedence (see `init`). Use `try?` for an
    /// optional result.
    /// - Throws: `AltitudeConversionError.missingGroundElevation` if only the ground elevation is
    ///   missing, otherwise `.missingTemperatureProfile`.
    public var seaLevelTemperature: Measurement<UnitTemperature> {
        get throws(AltitudeConversionError) {
            // Surface temperature takes precedence when it can be extrapolated down (see `init`)
            guard let surfaceTemp = _surfaceTemperature,
                  let elevation = groundElevation,
                  let lapse = lapseRate else {
                if let explicitTemp = _seaLevelTemperature {
                    return explicitTemp
                }
                throw missingDataToMove(_surfaceTemperature)
            }

            let seaLevelTempKelvin = surfaceTemp.kelvin + (lapse * elevation.meters)
            return .init(kelvin: seaLevelTempKelvin)
        }
    }

    // MARK: - Private Helpers

    /// Why `source` couldn't be carried between sea level and ground elevation: just the
    /// elevation when there's a temperature and lapse rate to carry, otherwise the profile.
    private func missingDataToMove(_ source: Measurement<UnitTemperature>?) -> AltitudeConversionError {
        source != nil && lapseRate != nil ? .missingGroundElevation : .missingTemperatureProfile
    }
}
