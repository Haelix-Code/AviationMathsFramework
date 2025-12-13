import Foundation

@resultBuilder
public struct AtmosphericProfileBuilder {
    public static func buildBlock(_ layers: AtmosphericLayer...) -> [AtmosphericLayer] {
        layers.sorted { $0.altitude.meters < $1.altitude.meters }
    }

    public static func buildArray(_ components: [[AtmosphericLayer]]) -> [AtmosphericLayer] {
        components.flatMap { $0 }.sorted { $0.altitude.meters < $1.altitude.meters }
    }

    public static func buildOptional(_ component: [AtmosphericLayer]?) -> [AtmosphericLayer] {
        component ?? []
    }

    public static func buildEither(first component: [AtmosphericLayer]) -> [AtmosphericLayer] {
        component
    }

    public static func buildEither(second component: [AtmosphericLayer]) -> [AtmosphericLayer] {
        component
    }
}

public struct AtmosphericProfile: Codable, Equatable, Sendable  {
    public let layers: [AtmosphericLayer]

    public init(@AtmosphericProfileBuilder _ builder: () -> [AtmosphericLayer]) {
        self.layers = builder()
    }

    public init(layers: [AtmosphericLayer]) {
        self.layers = layers.sorted { $0.altitude.meters < $1.altitude.meters }
    }

    public var winds: [Wind] { layers.map(\.wind) }

    public func wind(at altitude: Measurement<UnitLength>) -> Wind? {
        layers.winds.interpolated(at: altitude)
    }

    public func temperature(at altitude: Measurement<UnitLength>) -> Measurement<UnitTemperature>? {
        layers.temperature(at: altitude)
    }
}

// Convenience initializer for AtmosphericLayer
extension AtmosphericLayer {
    public static func layer(
        altitude: Double,
        windFrom: Double,
        windSpeed: Double,
        temperature: Double
    ) -> AtmosphericLayer {
        AtmosphericLayer(
            altitude: .init(feet: altitude),
            windFromDirection: .init(degrees: windFrom),
            windSpeed: .init(knots: windSpeed),
            temperature: .init(celsius: temperature)
        )
    }
}
