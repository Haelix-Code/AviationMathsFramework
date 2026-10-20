import Foundation

public extension SpeedContext {
    static func at(altitude: Altitude) -> SpeedContext {
        let amsl = altitude.amsl
        let ac = altitude.context

        // Prefer the context's lapse-adjusted temperature at the *actual*
        // altitude; `temperatureAtReference` alone is only valid verbatim if
        // amsl happens to equal temperatureReferenceAltitudeAMSL, so it's a
        // last resort before falling back to the ISA standard atmosphere.
        let t: Measurement<UnitTemperature> =
            ac.temperature(at: amsl)
            ?? ac.temperatureAtReference
            ?? ISA.temperature(at: amsl) // or SpeedContext.isaTemperature(at:)

        if let qnh = ac.qnh {
            return SpeedContext.fromQNHAndAMSL(
                qnh: qnh,
                amsl: amsl,
                measuredTemperature: t
            )
        } else {
            return SpeedContext(
                pressureAltitude: altitude.pressureAltitude,
                measuredTemperature: t
            )
        }
    }
}
