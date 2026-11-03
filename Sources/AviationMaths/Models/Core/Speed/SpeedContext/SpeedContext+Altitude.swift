import Foundation

public extension SpeedContext {
    /// A speed context at `altitude`.
    ///
    /// If the altitude can't be placed in pressure terms (e.g. AMSL with no QNH, or AGL
    /// with no ground elevation), the result carries only what is known (temperature, if
    /// any), so conversions that need pressure throw instead of this call trapping.
    static func at(altitude: Altitude) -> SpeedContext {
        let ac = altitude.context

        guard let amsl = try? altitude.value(in: .amsl) else {
            guard let pressureAltitude = try? altitude.value(in: .pressureAltitude) else {
                return SpeedContext(temperature: ac.temperatureAtReference)
            }
            return SpeedContext(
                pressureAltitude: pressureAltitude,
                measuredTemperature: ac.temperatureAtReference ?? ISA.temperature(at: pressureAltitude)
            )
        }

        // Prefer the context's lapse-adjusted temperature at the *actual*
        // altitude; `temperatureAtReference` alone is only valid verbatim if
        // amsl happens to equal temperatureReferenceAltitudeAMSL, so it's a
        // last resort before falling back to the ISA standard atmosphere.
        let t: Measurement<UnitTemperature> =
            ac.temperature(at: amsl)
            ?? ac.temperatureAtReference
            ?? ISA.temperature(at: amsl) // or SpeedContext.isaTemperature(at:)

        guard let qnh = ac.qnh else {
            // Without QNH an AMSL height can't be turned into a pressure
            return SpeedContext(temperature: t)
        }
        return SpeedContext.fromQNHAndAMSL(
            qnh: qnh,
            amsl: amsl,
            measuredTemperature: t
        )
    }
}
