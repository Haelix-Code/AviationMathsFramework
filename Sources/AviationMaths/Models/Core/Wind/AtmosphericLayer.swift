import Foundation

/// Represents atmospheric conditions at a specific altitude.
public struct AtmosphericLayer: Equatable, Sendable {
    public let altitude: Measurement<UnitLength>
    public let wind: Wind
    public let temperature: Measurement<UnitTemperature>

    public init(wind: Wind, temperature: Measurement<UnitTemperature>) {
        self.altitude = wind.altitude
        self.wind = wind
        self.temperature = temperature
    }

    public init(
        altitude: Measurement<UnitLength>,
        fromDirection: Measurement<UnitAngle>,
        speed: Measurement<UnitSpeed>,
        temperature: Measurement<UnitTemperature>
    ) {
        self.altitude = altitude
        self.wind = Wind(altitude: altitude, fromDirection: fromDirection, speed: speed)
        self.temperature = temperature
    }
}

public extension [AtmosphericLayer] {

    var winds: [Wind] {
        self.map { $0.wind }
    }

    var temperatureProfile: [(altitude: Measurement<UnitLength>, temperature: Measurement<UnitTemperature>)] {
        self.map { ($0.altitude, $0.temperature) }
    }

    func temperature(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature>? {
        guard !isEmpty else { return nil }

        let sortedLayers = sorted { $0.altitude.feet < $1.altitude.feet }

        guard isWithinRange(altitude: altitude, layers: sortedLayers) else {
            return nil
        }

        if let exactTemp = findExactMatch(altitude: altitude, in: sortedLayers) {
            return exactTemp
        }

        return interpolateTemperature(at: altitude, from: sortedLayers)
    }

    private func isWithinRange(
        altitude: Measurement<UnitLength>,
        layers: [Element]
    ) -> Bool {
        guard let first = layers.first, let last = layers.last else {
            return false
        }

        return altitude.feet >= first.altitude.feet &&
               altitude.feet <= last.altitude.feet
    }

    private func findExactMatch(
        altitude: Measurement<UnitLength>,
        in layers: [Element]
    ) -> Measurement<UnitTemperature>? {
        layers.first(where: { $0.altitude.feet == altitude.feet })?.temperature
    }

    private func interpolateTemperature(
        at altitude: Measurement<UnitLength>,
        from layers: [Element]
    ) -> Measurement<UnitTemperature>? {
        guard let upperIndex = layers.firstIndex(where: { $0.altitude.feet > altitude.feet }) else {
            return nil
        }

        let lowerIndex = upperIndex - 1
        let lowerLayer = layers[lowerIndex]
        let upperLayer = layers[upperIndex]

        // Linear interpolation
        let fraction = calculateInterpolationFraction(
            target: altitude.feet,
            lower: lowerLayer.altitude.feet,
            upper: upperLayer.altitude.feet
        )

        let interpolatedCelsius = linearInterpolate(
            fraction: fraction,
            lower: lowerLayer.temperature.celsius,
            upper: upperLayer.temperature.celsius
        )

        return Measurement<UnitTemperature>(celsius: interpolatedCelsius)
    }

    private func calculateInterpolationFraction(
        target: Double,
        lower: Double,
        upper: Double
    ) -> Double {
        let range = upper - lower
        let delta = target - lower
        return delta / range
    }

    /// Linear interpolation between two values
    private func linearInterpolate(
        fraction: Double,
        lower: Double,
        upper: Double
    ) -> Double {
        let range = upper - lower
        return lower + (fraction * range)
    }
}

extension AtmosphericLayer: Encodable {
    enum CodingKeys: String, CodingKey {
        case altitude
        case wind
        case temperature
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(wind, forKey: .wind)
        try container.encode(temperature, forKey: .temperature)
    }
}

extension AtmosphericLayer: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let altitude = try container.decode(Measurement<UnitLength>.self, forKey: .altitude)
        let wind = try container.decode(Wind.self, forKey: .wind)
        let temperature = try container.decode(Measurement<UnitTemperature>.self, forKey: .temperature)

        self.altitude = altitude
        self.wind = wind
        self.temperature = temperature
    }
}
