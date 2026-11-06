import Foundation

public struct Position2D: Equatable, Hashable, Codable, Sendable {
    public let latitude: Latitude
    public let longitude: Longitude

    public init(latitude: Latitude, longitude: Longitude) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(latitude: Double, longitude: Double) throws(CoordinateError) {
        self.latitude = try Latitude(decimalDegrees: latitude)
        self.longitude = try Longitude(decimalDegrees: longitude)
    }

    public init(
        latitudeDMS: DegreesMinutesSeconds,
        latitudeDirection: LatitudeDirection,
        longitudeDMS: DegreesMinutesSeconds,
        longitudeDirection: LongitudeDirection
    ) throws(CoordinateError) {
        self.latitude = try Latitude(dms: latitudeDMS, direction: latitudeDirection)
        self.longitude = try Longitude(dms: longitudeDMS, direction: longitudeDirection)
    }

    public init(
        latitudeDDM: DegreesDecimalMinutes,
        latitudeDirection: LatitudeDirection,
        longitudeDDM: DegreesDecimalMinutes,
        longitudeDirection: LongitudeDirection
    ) throws(CoordinateError) {
        self.latitude = try Latitude(ddm: latitudeDDM, direction: latitudeDirection)
        self.longitude = try Longitude(ddm: longitudeDDM, direction: longitudeDirection)
    }

    public init(
        latDegrees: Int,
        latMinutes: Int,
        latSeconds: Double,
        latDirection: LatitudeDirection,
        lonDegrees: Int,
        lonMinutes: Int,
        lonSeconds: Double,
        lonDirection: LongitudeDirection
    ) throws(CoordinateError) {
        self.latitude = try Latitude(
            degrees: latDegrees,
            minutes: latMinutes,
            seconds: latSeconds,
            direction: latDirection
        )
        self.longitude = try Longitude(
            degrees: lonDegrees,
            minutes: lonMinutes,
            seconds: lonSeconds,
            direction: lonDirection
        )
    }
}
