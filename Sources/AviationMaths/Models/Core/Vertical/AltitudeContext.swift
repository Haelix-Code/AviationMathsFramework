import Foundation

/// Context for altitude conversions, defining the atmospheric conditions.
public struct AltitudeContext: Sendable, Equatable, Codable {
    public let groundElevation: Measurement<UnitLength>?
    public let qnh: Measurement<UnitPressure>?

    private let _surfaceTemperature: Measurement<UnitTemperature>?
    private let _seaLevelTemperature: Measurement<UnitTemperature>?

    public let temperatureReferenceAltitudeAMSL: Measurement<UnitLength>?
    public let temperatureAtReference: Measurement<UnitTemperature>?

    public let lapseRate: Double?

    /// Surface temperature (at ground elevation)
    public var surfaceTemperature: Measurement<UnitTemperature>? {
        if let temp = _surfaceTemperature {
            return temp
        }
        guard let slTemp = _seaLevelTemperature,
              let elev = groundElevation,
              let rate = lapseRate else {
            return nil
        }
        let surfaceTemp = slTemp.kelvin - rate * elev.meters
        return .init(kelvin: surfaceTemp)
    }

    /// Sea level temperature (at height = 0)
    public var seaLevelTemperature: Measurement<UnitTemperature>? {
        if let temp = _seaLevelTemperature {
            return temp
        }
        guard let surfTemp = _surfaceTemperature,
              let elev = groundElevation,
              let rate = lapseRate else {
            return nil
        }
        let slTemp = surfTemp.kelvin + rate * elev.meters
        return .init(kelvin: slTemp)
    }

    /// Whether this context has sufficient data for true altitude calculations
    public var canCalculateTrueAltitude: Bool {
        seaLevelTemperature != nil && lapseRate != nil
    }

    /// Whether this context has sufficient data for AGL calculations
    public var canCalculateAGL: Bool {
        groundElevation != nil
    }

    /// Whether this context has sufficient data for pressure altitude calculations
    public var canCalculatePressureAltitude: Bool {
        qnh != nil
    }

    // MARK: - Full Initialiser (Maximum Flexibility)

    /// Creates an altitude context with full control over all parameters.
    ///
    /// - Parameters:
    /// - groundElevation: Elevation of the ground/terrain above mean sea level
    /// - qnh: Local barometric pressure adjusted to sea level
    /// - surfaceTemperature: Actual temperature at ground elevation
    /// - seaLevelTemperature: Actual temperature extrapolated to sea level
    /// - temperatureReferenceAltitude: Altitude of a known temperature measurement
    /// - temperatureAtReference: Temperature at the reference altitude
    /// - lapseRate: Temperature lapse rate in K/m (default ISA is 0.0065)
    ///
    /// - Note: Provide either `surfaceTemperature` or `seaLevelTemperature`, not both.
    /// If both are provided, `surfaceTemperature` takes precedence.
    public init(
        groundElevation: Measurement<UnitLength>? = nil,
        qnh: Measurement<UnitPressure>? = nil,
        surfaceTemperature: Measurement<UnitTemperature>? = nil,
        seaLevelTemperature: Measurement<UnitTemperature>? = nil,
        temperatureReferenceAltitudeAMSL: Measurement<UnitLength>? = nil,
        temperatureAtReference: Measurement<UnitTemperature>? = nil,
        lapseRate: Double? = nil
    ) {
        self.groundElevation = groundElevation
        self.qnh = qnh
        self._surfaceTemperature = surfaceTemperature
        self._seaLevelTemperature = seaLevelTemperature
        self.temperatureReferenceAltitudeAMSL = temperatureReferenceAltitudeAMSL
        self.temperatureAtReference = temperatureAtReference

        // Calculate lapse rate if not provided but we have the data
        if let lapseRate = lapseRate {
            self.lapseRate = lapseRate
        } else if let surfTemp = surfaceTemperature,
                  let altTemp = temperatureAtReference,
                  let tempAlt = temperatureReferenceAltitudeAMSL,
                  let elev = groundElevation {
            let temperatureDifference = surfTemp.kelvin - altTemp.kelvin
            let altitudeDifference = tempAlt.meters - elev.meters
            self.lapseRate = altitudeDifference != 0 ? temperatureDifference / altitudeDifference : nil
        } else if let slTemp = seaLevelTemperature,
                  let altTemp = temperatureAtReference,
                  let tempAlt = temperatureReferenceAltitudeAMSL {
            let temperatureDifference = slTemp.kelvin - altTemp.kelvin
            let altitudeDifference = tempAlt.meters
            self.lapseRate = altitudeDifference != 0 ? temperatureDifference / altitudeDifference : nil
        } else {
            self.lapseRate = nil
        }
    }

    // MARK: - Factory Methods (Common Configurations)

    /// Standard ISA conditions at sea level.
    public static let standardISA = AltitudeContext(
        groundElevation: .surface,
        qnh: ISA.seaLevelPressure,
        seaLevelTemperature: ISA.seaLevelTemperature,
        lapseRate: ISA.troposphereLapseRate
    )

    /// Creates a context for QNH-based conversions without temperature correction.
    ///
    /// Use this when you only need to convert between AMSL, AGL, and Pressure Altitude,
    /// and don't need True Altitude calculations.
    ///
    /// - Parameters:
    /// - hectopascals: QNH in hectopascals (hPa/mb)
    /// - groundElevation: Ground elevation above mean sea level
    public static func qnhOnly(
        hectopascals: Double,
        groundElevation: Measurement<UnitLength>
    ) -> AltitudeContext {
        AltitudeContext(
            groundElevation: groundElevation,
            qnh: .init(hectopascals: hectopascals)
        )
    }

    /// Creates a context with surface temperature for full altitude conversions.
    ///
    /// - Parameters:
    /// - groundElevation: Ground elevation above mean sea level
    /// - qnh: Local QNH pressure
    /// - surfaceTemp: Actual temperature at ground level
    /// - lapseRate: Temperature lapse rate (defaults to ISA standard 0.0065 K/m)
    public static func withSurfaceTemperature(
        groundElevation: Measurement<UnitLength>,
        qnh: Measurement<UnitPressure>,
        surfaceTemp: Measurement<UnitTemperature>,
        lapseRate: Double = ISA.troposphereLapseRate
    ) -> AltitudeContext {
        AltitudeContext(
            groundElevation: groundElevation,
            qnh: qnh,
            surfaceTemperature: surfaceTemp,
            lapseRate: lapseRate
        )
    }

    /// Creates a context from ISA deviation (delta ISA).
    ///
    /// - Parameters:
    /// - groundElevation: Ground elevation above mean sea level
    /// - qnh: Local QNH pressure
    /// - deltaISA: Temperature deviation from ISA in degrees (positive = hotter)
    public static func withDeltaISA(
        groundElevation: Measurement<UnitLength>,
        qnh: Measurement<UnitPressure>,
        deltaISA: Double
    ) -> AltitudeContext {
        let isaTemp = ISA.temperature(at: groundElevation)
        let actualTemp = Measurement<UnitTemperature>(kelvin: isaTemp.kelvin + deltaISA)

        return AltitudeContext(
            groundElevation: groundElevation,
            qnh: qnh,
            surfaceTemperature: actualTemp,
            lapseRate: ISA.troposphereLapseRate
        )
    }

    /// Creates a context for pressure altitude only (standard pressure, no QNH).
    ///
    /// Use this when working purely in pressure altitude with no local corrections.
    public static func pressureAltitudeOnly(
        groundElevation: Measurement<UnitLength>? = nil
    ) -> AltitudeContext {
        AltitudeContext(
            groundElevation: groundElevation,
            qnh: ISA.seaLevelPressure,
            seaLevelTemperature: ISA.seaLevelTemperature,
            lapseRate: ISA.troposphereLapseRate
        )
    }

    // MARK: - Temperature Calculation

    /// Calculate temperature at any altitude using the temperature model
    public func temperature(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature>? {
        guard let slTemp = seaLevelTemperature,
              let rate = lapseRate else {
            return nil
        }
        let tempAtAlt = slTemp.kelvin - rate * altitude.meters
        return .init(kelvin: tempAtAlt)
    }
}

// MARK: - Lapse Rate Utility

extension AltitudeContext {
    /// Calculate lapse rate from two temperature measurements
    public static func calculateLapseRate(
        tempAtLowerAltitude: Measurement<UnitTemperature>,
        tempAtHigherAltitude: Measurement<UnitTemperature>,
        lowerAltitude: Measurement<UnitLength>,
        higherAltitude: Measurement<UnitLength>
    ) -> Double {
        let temperatureDifference = tempAtLowerAltitude.kelvin - tempAtHigherAltitude.kelvin
        let altitudeDifference = higherAltitude.meters - lowerAltitude.meters
        return temperatureDifference / altitudeDifference
    }
}
