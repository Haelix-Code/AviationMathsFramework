extension Position2D {
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
