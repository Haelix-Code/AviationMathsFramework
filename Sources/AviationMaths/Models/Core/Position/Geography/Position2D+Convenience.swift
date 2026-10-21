import GeodesySpherical

extension Position2D {
    public init(coordinate: Coordinate) {
        // Geodesic math (e.g. a destination point computed right at a pole or across the
        // antimeridian) can overshoot the valid range by floating-point noise; clamp rather
        // than let the precondition in Latitude/Longitude's initializer trap on it.
        self.latitude = Latitude(decimalDegrees: coordinate.latitude.clamped(to: Latitude.validRange))
        self.longitude = Longitude(decimalDegrees: coordinate.longitude.clamped(to: Longitude.validRange))
    }

    public var latitudeDecimalDegrees: Double {
        latitude.decimalDegrees
    }
    public var longitudeDecimalDegrees: Double {
        longitude.decimalDegrees
    }

    public var latitudeDirection: LatitudeDirection {
        latitude.direction
    }
    public var longitudeDirection: LongitudeDirection {
        longitude.direction
    }

    public var latitudeDMS: DegreesMinutesSeconds {
        latitude.degreesMinutesSeconds
    }
    public var longitudeDMS: DegreesMinutesSeconds {
        longitude.degreesMinutesSeconds
    }

    public var latitudeDDM: DegreesDecimalMinutes {
        latitude.degreesDecimalMinutes
    }
    public var longitudeDDM: DegreesDecimalMinutes {
        longitude.degreesDecimalMinutes
    }
}

extension Position2D: CustomStringConvertible {
    public var description: String {
        "\(latitude) \(longitude)"
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
