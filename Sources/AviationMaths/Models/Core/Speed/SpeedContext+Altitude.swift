import Foundation

public extension SpeedContext {
    static func at(altitude: Altitude) -> SpeedContext {
        let amsl = altitude.amsl
        let ac = altitude.context

        // Prefer a measured reference temperature if present; otherwise, use
        // the context's derived temperature (surface + lapse) or ISA fallback.
        let t: Measurement<UnitTemperature> =
            ac.temperatureAtReference
            ?? ac.temperature(at: amsl)
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
