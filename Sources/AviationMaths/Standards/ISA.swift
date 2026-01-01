import Foundation

/// International Standard Atmosphere (ISA) model for aviation calculations.
///
/// Implements the ICAO Standard Atmosphere (ISO 2533:1975) for altitudes from 0 to 20,000 meters,
/// covering the troposphere (0-11km) and lower stratosphere (11-20km).
/// All units used in calculations are SI.
public struct ISA {

    // MARK: - Physical Constants

    public static let standardGravity: Measurement<UnitAcceleration> =
        .init(value: 9.80665, unit: .metersPerSecondSquared)
    public static let dryAirGasConstant: Double = 287.058
    public static let ratioSpecificHeats: Double = 1.4

    public static let seaLevelPressure: Measurement<UnitPressure> =
        .init(value: 1.01325e5, unit: .newtonsPerMetersSquared)
    public static let seaLevelTemperature: Measurement<UnitTemperature> =
        .init(value: 288.15, unit: .kelvin)
    public static let seaLevelDensity: Measurement<UnitConcentrationMass> =
        .init(value: 1.225, unit: .gramsPerLiter)
    public static let seaLevelSpeedOfSound: Measurement<UnitSpeed> =
        .init(value: 340.294, unit: .metersPerSecond)
    internal static let molarMassDryAir: Double = 0.028964
    internal static let idealGasConstant: Double = 8.3144598

    // MARK: - Atmospheric Layer Definitions

    private static let troposphereBase: Measurement<UnitLength> = .init(value: 0, unit: .meters)
    private static let lowerStratosphereBase: Measurement<UnitLength> = .init(value: 11_000, unit: .meters)
    private static let modelUpperLimit: Measurement<UnitLength> = .init(value: 20_000, unit: .meters)
    public static let troposphereLapseRate: Double = 0.0065  // K/m
    private static let lowerStratosphereLapseRate: Double = 0.0
    private static let tropopauseTemperature: Measurement<UnitTemperature> = .init(
        value: seaLevelTemperature.value - troposphereLapseRate
            * (lowerStratosphereBase.meters - troposphereBase.meters),
        unit: .kelvin)

    // MARK: - Instance Properties

    public let altitude: Measurement<UnitLength>
    public let deltaISA: Measurement<UnitTemperature>

    // MARK: - Initializers

    public init(altitude: Measurement<UnitLength>,
                deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)) {
        let altitudeMeters = altitude.meters

        if altitudeMeters < -5000 {
            self.altitude = .init(meters: -5000)
        } else if altitudeMeters > Self.modelUpperLimit.meters {
            self.altitude = altitude
        } else {
            self.altitude = altitude
        }

        self.deltaISA = deltaISA
    }

    public init(altitudeMeters: Double, deltaISA: Double = 0) {
        self.init(
            altitude: .init(meters: altitudeMeters),
            deltaISA: .init(kelvin: deltaISA)
        )
    }

    public init(altitudeFeet: Double, deltaISA: Double = 0) {
        self.init(
            altitude: .init(feet: altitudeFeet),
            deltaISA: .init(kelvin: deltaISA)
        )
    }

    public static func seaLevel(deltaISA: Double = 0) -> ISA {
        return ISA(altitudeMeters: 0, deltaISA: deltaISA)
    }

    // MARK: - Computed Properties

    public var temperature: Measurement<UnitTemperature> {
        let altitudeMeters = altitude.meters
        let deltaK = deltaISA.kelvin

        let standardTemp: Double
        if altitudeMeters < Self.lowerStratosphereBase.meters {
            // Troposphere: T = T₀ - L × h (temperature decreases with altitude)
            standardTemp = Self.seaLevelTemperature.value -
                          Self.troposphereLapseRate * altitudeMeters
        } else {
            // Lower stratosphere: isothermal at tropopause temperature
            standardTemp = Self.tropopauseTemperature.kelvin
        }

        return .init(kelvin: standardTemp + deltaK)
    }

    public var pressure: Measurement<UnitPressure> {
            let altitudeMeters = altitude.meters

            // Handle negative altitudes (below sea level)
            if altitudeMeters < 0 {
                return pressureBelowSeaLevel(altitudeMeters: altitudeMeters)
            }

            // Calculate through troposphere
            var state = AtmosphericState(
                pressure: ISA.seaLevelPressure.pascals,
                temperature: ISA.seaLevelTemperature.kelvin,
                altitude: 0.0
            )

            // Apply troposphere layer (0 to tropopause)
            if altitudeMeters >= 0 {
                let topOfTroposphere = min(altitudeMeters, Self.lowerStratosphereBase.meters)
                state = applyTroposphereLayer(from: state, to: topOfTroposphere)
            }

            // Apply stratosphere layer if above tropopause
        if altitudeMeters >= Self.lowerStratosphereBase.meters {
                state = applyStratosphereLayer(from: state, to: altitudeMeters)
            }

            return .init(pascals: state.pressure)
        }

        /// Calculates pressure below sea level
        private func pressureBelowSeaLevel(altitudeMeters: Double) -> Measurement<UnitPressure> {
            let g = ISA.standardGravity.metersPerSecondSquared
            let R = ISA.dryAirGasConstant
            let L = 0.0065  // Lapse rate

            let temperatureAtAltitude = ISA.seaLevelTemperature.kelvin - (L * altitudeMeters)
            let temperatureRatio = temperatureAtAltitude / ISA.seaLevelTemperature.kelvin
            let exponent = g / (L * R)

            let pressurePa = ISA.seaLevelPressure.pascals * pow(temperatureRatio, exponent)
            return .init(pascals: pressurePa)
        }

        /// Applies pressure change through troposphere (temperature decreases with altitude)
        private func applyTroposphereLayer(
            from initialState: AtmosphericState,
            to targetAltitude: Double
        ) -> AtmosphericState {
            let g = ISA.standardGravity.metersPerSecondSquared
            let R = ISA.dryAirGasConstant
            let L = 0.0065  // Troposphere lapse rate (K/m)

            let deltaAltitude = targetAltitude - initialState.altitude
            let finalTemperature = initialState.temperature - (L * deltaAltitude)
            let temperatureRatio = finalTemperature / initialState.temperature
            let exponent = g / (L * R)

            let finalPressure = initialState.pressure * pow(temperatureRatio, exponent)

            return AtmosphericState(
                pressure: finalPressure,
                temperature: finalTemperature,
                altitude: targetAltitude
            )
        }

        /// Applies pressure change through stratosphere (isothermal layer)
        private func applyStratosphereLayer(
            from initialState: AtmosphericState,
            to targetAltitude: Double
        ) -> AtmosphericState {
            let g = ISA.standardGravity.metersPerSecondSquared
            let R = ISA.dryAirGasConstant

            let deltaAltitude = targetAltitude - initialState.altitude
            let exponent = -g * deltaAltitude / (R * initialState.temperature)
            let finalPressure = initialState.pressure * exp(exponent)

            return AtmosphericState(
                pressure: finalPressure,
                temperature: initialState.temperature,  // Isothermal
                altitude: targetAltitude
            )
        }

        /// Represents atmospheric state at a given altitude
        private struct AtmosphericState {
            let pressure: Double      // Pa
            let temperature: Double   // K
            let altitude: Double      // m
        }

    public var density: Measurement<UnitConcentrationMass> {
        let pressurePa = pressure.pascals
        let tempK = temperature.kelvin
        let rho = pressurePa / (Self.dryAirGasConstant * tempK)

        return .init(value: rho, unit: .gramsPerLiter)
    }

    public var relativeDensity: Double {
        let relativeDensity = density
            .converted(to: .gramsPerLiter).value
        / ISA.seaLevelDensity
            .converted(to: .gramsPerLiter).value
        return relativeDensity
    }

    public var densityAltitude: Measurement<UnitLength> {
        let rho = density.converted(to: .gramsPerLiter).value

        let g = Self.standardGravity.value
        let R = Self.dryAirGasConstant
        let L = Self.troposphereLapseRate

        let T0 = Self.seaLevelTemperature.value
        let P0 = Self.seaLevelPressure.value
        let rho0 = Self.seaLevelDensity.converted(to: .gramsPerLiter).value
        let Ht = Self.lowerStratosphereBase.meters
        let Tt = Self.tropopauseTemperature.value

        let exponentTroposphere = g / (L * R)
        let Pt = P0 * pow(Tt / T0, exponentTroposphere)

        let rhot = Pt / (R * Tt)

        if rho >= rhot {
            let exponent = (g / (L * R)) - 1.0
            let ratio = rho / rho0
            let h = (T0 / L) * (1.0 - pow(ratio, 1.0 / exponent))
            return .init(meters: h)
        } else {
            let h = Ht - ((R * Tt) / g) * log(rho / rhot)
            return .init(meters: h)
        }
    }

    public var speedOfSound: Measurement<UnitSpeed> {
        let tempK = temperature.kelvin
        let speedMS = sqrt(Self.ratioSpecificHeats * Self.dryAirGasConstant * tempK)

        return .init(mps: speedMS)
    }

    public var lapseRate: Double {
        let altitudeMeters = altitude.meters
        if altitudeMeters > Self.lowerStratosphereBase.meters {
            return Self.lowerStratosphereLapseRate
        } else {
            return Self.troposphereLapseRate
        }
    }
}

// MARK: - Static Calculation Methods

extension ISA {
    public static func temperature(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitTemperature> {
        return ISA(altitude: altitude, deltaISA: deltaISA).temperature
    }

    public static func pressure(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitPressure> {
        return ISA(altitude: altitude, deltaISA: deltaISA).pressure
    }

    public static func density(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitConcentrationMass> {
        return ISA(altitude: altitude, deltaISA: deltaISA).density
    }

    public static func relativeDensity(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Double {
        let density = density(at: altitude, deltaISA: deltaISA)
        let relativeDensity = density
            .converted(to: .gramsPerLiter).value
        / ISA.seaLevelDensity
            .converted(to: .gramsPerLiter).value

        return relativeDensity
    }

    public static func densityAltitude(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitLength> {
        return ISA(altitude: altitude, deltaISA: deltaISA).densityAltitude
    }

    public static func speedOfSound(
        at altitude: Measurement<UnitLength>,
        deltaISA: Measurement<UnitTemperature> = .init(kelvin: 0)
    ) -> Measurement<UnitSpeed> {
        return ISA(altitude: altitude, deltaISA: deltaISA).speedOfSound
    }

    public static func lapseRate(
        at altitude: Measurement<UnitLength>) -> Double {
            return ISA(altitude: altitude).lapseRate
        }
}

extension ISA {
    /// Calculate desnity from pressure and temperature using ideal gas law
    /// \(\rho \) = P / ( R x T)
    public static func densityFromPressureAndTemperature(
        pressure: Measurement<UnitPressure>,
        temperature: Measurement<UnitTemperature>
    ) -> Measurement<UnitConcentrationMass> {
        let rho = pressure.pascals / (ISA.dryAirGasConstant * temperature.kelvin)
        return .init(value: rho, unit: .gramsPerLiter)
    }

    // a = ((\sqrt \) \gamma x R  x T)
    public static func speedOfSoundFromTemperature(
        temperature: Measurement<UnitTemperature>
    ) -> Measurement<UnitSpeed> {
        let speedMS = sqrt(ISA.ratioSpecificHeats * ISA.dryAirGasConstant * temperature.kelvin)
        return .init(mps: speedMS)
    }

    public static func pressureFromQNHAndAMSL(
        qnh: Measurement<UnitPressure>,
        amsl: Measurement<UnitLength>
    ) -> Measurement<UnitPressure> {
        let h = amsl.converted(to: .meters).value
        let T0 = ISA.seaLevelTemperature.kelvin
        let L  = ISA.troposphereLapseRate
        let g  = ISA.standardGravity
        let R  = ISA.dryAirGasConstant

        let tempRatio = max(1e-9, (T0 - L * h) / T0)
        let exponent = g.metersPerSecondSquared / (L * R)
        let p = qnh.converted(to: .pascals).value * pow(tempRatio, exponent)
        return .init(value: p, unit: .pascals)
    }

}
