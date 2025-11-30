import Foundation

/// Represents atmospheric conditions at a specific altitude.
public struct AtmosphericLayer: Equatable {
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
        windFromDirection: Measurement<UnitAngle>,
        windSpeed: Measurement<UnitSpeed>,
        temperature: Measurement<UnitTemperature>
    ) {
        self.altitude = altitude
        self.wind = Wind(altitude: altitude, fromDirection: windFromDirection, speed: windSpeed)
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

        let sortedLayers = self.sorted { $0.altitude.feet < $1.altitude.feet }

        guard altitude.feet >= sortedLayers.first!.altitude.feet,
              altitude.feet <= sortedLayers.last!.altitude.feet else {
            return nil
        }

        if let exactLayer = sortedLayers.first(where: { $0.altitude.feet == altitude.feet }) {
            return exactLayer.temperature
        }

        guard let upperIndex = sortedLayers.firstIndex(where: { $0.altitude.feet > altitude.feet }) else {
            return nil
        }

        let lowerIndex = upperIndex - 1
        let lowerLayer = sortedLayers[lowerIndex]
        let upperLayer = sortedLayers[upperIndex]

        let altRange = upperLayer.altitude.feet - lowerLayer.altitude.feet
        let altDelta = altitude.feet - lowerLayer.altitude.feet
        let fraction = altDelta / altRange

        let tempRange = upperLayer.temperature.celsius - lowerLayer.temperature.celsius
        let interpolatedTemp = lowerLayer.temperature.celsius + (fraction * tempRange)

        return Measurement<UnitTemperature>(celsius: interpolatedTemp)
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
