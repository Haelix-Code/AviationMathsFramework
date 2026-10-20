import Foundation

/// A piecewise-linear temperature profile over the ICAO Standard Atmosphere's layers
/// (ICAO Doc 7488, geopotential −5 km to 80 km), with pressure from the hydrostatic
/// equation integrated through each layer.
///
/// `standard` is the ISA itself. `BarometricEquations` builds non-standard instances
/// that keep the ICAO layer structure but start from a different base pressure (a QNH
/// datum), base temperature or lowest-layer lapse rate; temperature stays continuous
/// across every layer boundary.
///
/// Above every non-standard instance's 11 km boundary, temperature is the ISA's plus a
/// constant deviation (the deviation at 11 km), i.e. ISA + ΔISA, the flight-test convention.
///
/// Outside −5…80 km the bottom and top layers are extrapolated; see `ISA.validAltitudeRange`.
internal struct LayeredAtmosphere: Sendable {

    /// Geopotential base (m) and lapse rate (K/m, positive = cooling with height) of each
    /// ICAO layer. The first layer's lapse rate can be overridden.
    static let icaoLayers: [(base: Double, lapseRate: Double)] = [
        (0, 0.0065),        // troposphere
        (11_000, 0),        // tropopause
        (20_000, -0.0010),  // stratosphere
        (32_000, -0.0028),
        (47_000, 0),        // stratopause
        (51_000, 0.0028),   // mesosphere
        (71_000, 0.0020)
    ]

    static let standard = LayeredAtmosphere(
        baseTemperature: ISA.seaLevelTemperature.kelvin,
        basePressure: ISA.seaLevelPressure.pascals,
        lowestLayerLapseRate: ISA.troposphereLapseRate
    )

    private struct Layer {
        let base: Double
        let lapseRate: Double
        let baseTemperature: Double
        let basePressure: Double

        var baseDensity: Double { basePressure / (ISA.dryAirGasConstant * baseTemperature) }
        private var isIsothermal: Bool { abs(lapseRate) < 1e-12 }

        func temperature(at h: Double) -> Double {
            baseTemperature - lapseRate * (h - base)
        }

        func pressure(at h: Double) -> Double {
            let g = ISA.standardGravity.metersPerSecondSquared
            let R = ISA.dryAirGasConstant
            if isIsothermal {
                return basePressure * exp(-g * (h - base) / (R * baseTemperature))
            }
            return basePressure * pow(temperature(at: h) / baseTemperature, g / (R * lapseRate))
        }

        func altitude(atPressure p: Double) -> Double {
            let g = ISA.standardGravity.metersPerSecondSquared
            let R = ISA.dryAirGasConstant
            if isIsothermal {
                return base + (R * baseTemperature / g) * log(basePressure / p)
            }
            return base + (baseTemperature / lapseRate) * (1 - pow(p / basePressure, R * lapseRate / g))
        }

        func altitude(atDensity rho: Double) -> Double {
            let g = ISA.standardGravity.metersPerSecondSquared
            let R = ISA.dryAirGasConstant
            if isIsothermal {
                return base + (R * baseTemperature / g) * log(baseDensity / rho)
            }
            // ρ/ρb = (T/Tb)^(g/(R·L) − 1)
            let exponent = g / (R * lapseRate) - 1
            return base + (baseTemperature / lapseRate) * (1 - pow(rho / baseDensity, 1 / exponent))
        }
    }

    private let layers: [Layer]

    /// - Parameters:
    ///   - baseTemperature: Temperature at height 0 (K).
    ///   - basePressure: Pressure at height 0 (Pa).
    ///   - lowestLayerLapseRate: Lapse rate of the bottom layer, up to 11 km (K/m).
    init(baseTemperature: Double, basePressure: Double, lowestLayerLapseRate: Double) {
        var layers: [Layer] = []
        for (index, icao) in Self.icaoLayers.enumerated() {
            let lapseRate = index == 0 ? lowestLayerLapseRate : icao.lapseRate
            guard let below = layers.last else {
                layers.append(Layer(base: icao.base, lapseRate: lapseRate,
                                    baseTemperature: baseTemperature, basePressure: basePressure))
                continue
            }
            layers.append(Layer(
                base: icao.base,
                lapseRate: lapseRate,
                baseTemperature: below.temperature(at: icao.base),
                basePressure: below.pressure(at: icao.base)
            ))
        }
        self.layers = layers
    }

    // Each layer starts AT its base: a height exactly on a boundary belongs to the layer above.

    private func layer(containing h: Double) -> Layer {
        layers.last(where: { $0.base <= h }) ?? layers[0]
    }

    func temperature(at h: Double) -> Double { layer(containing: h).temperature(at: h) }

    func pressure(at h: Double) -> Double { layer(containing: h).pressure(at: h) }

    func density(at h: Double) -> Double { pressure(at: h) / (ISA.dryAirGasConstant * temperature(at: h)) }

    func lapseRate(at h: Double) -> Double { layer(containing: h).lapseRate }

    func altitude(atPressure p: Double) -> Double {
        (layers.last(where: { $0.basePressure >= p }) ?? layers[0]).altitude(atPressure: p)
    }

    /// Height at which this atmosphere's own density equals `rho` (kg/m³).
    func altitude(atDensity rho: Double) -> Double {
        (layers.last(where: { $0.baseDensity >= rho }) ?? layers[0]).altitude(atDensity: rho)
    }
}
