import Vincenty

extension GeodeticCoordinate {
    public init(position2D: Position2D) {
        self.init(latitude: position2D.latitude.decimalDegrees, longitude: position2D.longitude.decimalDegrees)
    }
}
