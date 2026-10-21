import Foundation

@resultBuilder
public struct AtmosphericProfileBuilder {
    /// Lifts each layer into an array, so `if`, `switch` and `for` results (already
    /// arrays) can sit alongside plain layers in a block.
    public static func buildExpression(_ layer: AtmosphericLayer) -> [AtmosphericLayer] {
        [layer]
    }

    public static func buildBlock(_ components: [AtmosphericLayer]...) -> [AtmosphericLayer] {
        components.flatMap { $0 }.sorted { $0.altitude.meters < $1.altitude.meters }
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

public struct AtmosphericProfile: Codable, Equatable, Sendable {
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
        speed: Double,
        temperature: Double
    ) -> AtmosphericLayer {
        AtmosphericLayer(
            altitude: .init(feet: altitude),
            fromDirection: .init(degrees: windFrom),
            speed: .init(knots: speed),
            temperature: .init(celsius: temperature)
        )
    }
}
