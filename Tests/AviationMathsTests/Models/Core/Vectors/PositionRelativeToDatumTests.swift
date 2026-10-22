import XCTest
@testable import AviationMaths

/// Positions from a datum are geodesics on the WGS-84 ellipsoid (Vincenty), not great
/// circles on a sphere, which drift tens of metres off over tens of kilometres.
final class PositionRelativeToDatumTests: XCTestCase {

    // Geoscience Australia's Vincenty reference case: Flinders Peak → Buninyong.
    private let flindersPeak = Position2D(latitude: -37.951033416666666, longitude: 144.42486788888888)
    private let buninyong = Position2D(latitude: -37.65282113888889, longitude: 143.92649552777778)
    private let distance = Measurement<UnitLength>(meters: 54_972.271)
    private let bearing = Measurement<UnitAngle>(degrees: 306 + 52.0 / 60 + 5.37 / 3600)

    /// ~0.1 m. The published azimuth is to 0.01″, worth ~3 mm over this distance.
    private let accuracy = 0.000001

    private func assertIsBuninyong(_ position: Position2D, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(
            position.latitude.decimalDegrees, buninyong.latitude.decimalDegrees,
            accuracy: accuracy, "latitude", file: file, line: line
        )
        XCTAssertEqual(
            position.longitude.decimalDegrees, buninyong.longitude.decimalDegrees,
            accuracy: accuracy, "longitude", file: file, line: line
        )
    }

    func test_polarVector_followsEllipsoidalGeodesic() {
        let vector = LengthPolar(bearing: bearing, magnitude: distance)

        assertIsBuninyong(vector.positionRelativeToDatum(flindersPeak))
    }

    func test_cartesianVector_followsEllipsoidalGeodesic() {
        let vector = LengthPolar(bearing: bearing, magnitude: distance).lengthCartesianVector

        assertIsBuninyong(vector.positionRelativeToDatum(flindersPeak))
    }

    func test_geodesicPosition_followsEllipsoidalGeodesic() {
        let position = GeodesicPosition(bearing: bearing, range: distance, origin: GeodeticOrigin(flindersPeak))

        assertIsBuninyong(position.geodetic)
    }
}
