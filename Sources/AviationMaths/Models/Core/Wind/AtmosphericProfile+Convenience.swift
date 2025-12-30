import Foundation

public extension AtmosphericProfile {
    init(
        winds: [Wind],
        altitudeContext: AltitudeContext,
        fallbackToISA: Bool = true
    ) {
        func temp(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature> {
            if let t = altitudeContext.temperature(at: altitude) { return t }
            return fallbackToISA ? ISA(altitude: altitude).temperature : .init(kelvin: .nan)
        }

        let layers = winds.map { w in
            AtmosphericLayer(
                altitude: w.altitude,
                fromDirection: w.fromDirection,
                speed: w.speed,
                temperature: temp(at: w.altitude)
            )
        }

        self.init(layers: layers)
    }
}
