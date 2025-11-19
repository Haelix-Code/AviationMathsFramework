import GeodesySpherical

extension GeodesySpherical.Coordinate {
    public init(position2D: Position2D) {
        self.init(position2D.latitude.decimalDegrees, position2D.longitude.decimalDegrees)
    }

}
