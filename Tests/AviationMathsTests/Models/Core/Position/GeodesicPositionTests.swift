import XCTest
@testable import AviationMaths

final class GeodesicPositionTests: XCTestCase {
    
    private var origin: GeodeticOrigin {
        GeodeticOrigin(Position2D(
            latitude: 51.0,
            longitude: -1.0
        ))
    }
    
    func test_bearing_returnsRelativeBearing() {
        let pos = GeodesicPosition(
            bearing: .init(value: 45, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        XCTAssertEqual(pos.bearing.converted(to: .degrees).value, 45, accuracy: 0.01)
    }
    
    func test_range_returnsRelativeRange() {
        let pos = GeodesicPosition(
            bearing: .init(value: 0, unit: .degrees),
            range: .init(value: 5000, unit: .meters),
            origin: origin
        )
        
        XCTAssertEqual(pos.range.converted(to: .meters).value, 5000, accuracy: 0.01)
    }
    
    func test_geodetic_northBearing_increasesLatitude() {
        let pos = GeodesicPosition(
            bearing: .init(value: 0, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        XCTAssertGreaterThan(pos.geodetic.latitude.decimalDegrees, 51.0)
        XCTAssertEqual(pos.geodetic.longitude.decimalDegrees, -1.0, accuracy: 0.001)
    }
    
    func test_geodetic_zeroRange_returnsOrigin() {
        let pos = GeodesicPosition(
            bearing: .init(value: 0, unit: .degrees),
            range: .init(value: 0, unit: .meters),
            origin: origin
        )
        
        XCTAssertEqual(pos.geodetic.latitude.decimalDegrees, 51.0, accuracy: 0.0001)
        XCTAssertEqual(pos.geodetic.longitude.decimalDegrees, -1.0, accuracy: 0.0001)
    }
    
    func test_relativePosition_fromOrigin_createsGeodesicPosition() {
        let relative = RelativePosition(
            bearing: .init(value: 90, unit: .degrees),
            range: .init(value: 2000, unit: .meters)
        )
        
        let geodesic = relative.position(from: origin)
        
        XCTAssertEqual(geodesic.bearing.converted(to: .degrees).value, 90, accuracy: 0.01)
        XCTAssertEqual(geodesic.range.converted(to: .meters).value, 2000, accuracy: 0.01)
    }
    
    func test_summing_combinesRelativePositions() {
        let pos1 = GeodesicPosition(
            bearing: .init(value: 0, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        let pos2 = GeodesicPosition(
            bearing: .init(value: 0, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        let sum = GeodesicPosition(summing: [pos1, pos2])
        
        XCTAssertEqual(sum.range.converted(to: .meters).value, 2000, accuracy: 1)
    }
    
    func test_geodetic_eastBearing_increasesLongitude() {
        let pos = GeodesicPosition(
            bearing: .init(value: 90, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        XCTAssertEqual(pos.geodetic.latitude.decimalDegrees, 51.0, accuracy: 0.001)
        XCTAssertGreaterThan(pos.geodetic.longitude.decimalDegrees, -1.0)
    }
    
    func test_geodetic_southBearing_decreasesLatitude() {
        let pos = GeodesicPosition(
            bearing: .init(value: 180, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        XCTAssertLessThan(pos.geodetic.latitude.decimalDegrees, 51.0)
        XCTAssertEqual(pos.geodetic.longitude.decimalDegrees, -1.0, accuracy: 0.001)
    }
    
    func test_geodetic_westBearing_decreasesLongitude() {
        let pos = GeodesicPosition(
            bearing: .init(value: 270, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        XCTAssertEqual(pos.geodetic.latitude.decimalDegrees, 51.0, accuracy: 0.001)
        XCTAssertLessThan(pos.geodetic.longitude.decimalDegrees, -1.0)
    }
    
    func test_cartesianVector_returnsRelativeCartesian() {
        let pos = GeodesicPosition(
            bearing: .init(value: 45, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        let vector = pos.cartesianVector
        // 45° bearing means equal x and y components
        XCTAssertEqual(vector.x.value, vector.y.value, accuracy: 0.01)
        XCTAssertGreaterThan(vector.x.value, 0) // East component
        XCTAssertGreaterThan(vector.y.value, 0) // North component
    }
    
    func test_geodetic_largeDistance_calculatesCorrectly() {
        let pos = GeodesicPosition(
            bearing: .init(value: 0, unit: .degrees),
            range: .init(value: 100_000, unit: .meters), // 100 km
            origin: origin
        )
        
        // Should be approximately 1 degree north (1 degree ≈ 111 km at this latitude)
        XCTAssertGreaterThan(pos.geodetic.latitude.decimalDegrees, 51.0)
        XCTAssertLessThan(pos.geodetic.latitude.decimalDegrees, 52.0)
    }
    
    func test_equality_sameValues_areEqual() {
        let pos1 = GeodesicPosition(
            bearing: .init(value: 45, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        let pos2 = GeodesicPosition(
            bearing: .init(value: 45, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        XCTAssertEqual(pos1, pos2)
    }
    
    func test_equality_differentBearing_areNotEqual() {
        let pos1 = GeodesicPosition(
            bearing: .init(value: 45, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        let pos2 = GeodesicPosition(
            bearing: .init(value: 90, unit: .degrees),
            range: .init(value: 1000, unit: .meters),
            origin: origin
        )
        
        XCTAssertNotEqual(pos1, pos2)
    }
}

final class GeodeticOriginTests: XCTestCase {
    
    func test_equality_samePosition_areEqual() {
        let pos = Position2D(latitude: 51.5, longitude: -1.0)
        let origin1 = GeodeticOrigin(pos)
        let origin2 = GeodeticOrigin(pos)
        
        XCTAssertEqual(origin1, origin2)
    }
    
    func test_equality_differentPosition_areNotEqual() {
        let origin1 = GeodeticOrigin(Position2D(latitude: 51.5, longitude: -1.0))
        let origin2 = GeodeticOrigin(Position2D(latitude: 52.0, longitude: -1.0))
        
        XCTAssertNotEqual(origin1, origin2)
    }
    
    func test_hash_samePosition_produceSameHash() {
        let pos = Position2D(latitude: 51.5, longitude: -1.0)
        let origin1 = GeodeticOrigin(pos)
        let origin2 = GeodeticOrigin(pos)
        
        XCTAssertEqual(origin1.hashValue, origin2.hashValue)
    }
    
    func test_hash_canBeUsedInSet() {
        let origin1 = GeodeticOrigin(Position2D(latitude: 51.5, longitude: -1.0))
        let origin2 = GeodeticOrigin(Position2D(latitude: 51.5, longitude: -1.0))
        let origin3 = GeodeticOrigin(Position2D(latitude: 52.0, longitude: -1.0))
        
        let set = Set([origin1, origin2, origin3])
        
        // origin1 and origin2 are equal, so set should only contain 2 unique origins
        XCTAssertEqual(set.count, 2)
    }
    
    func test_position_returnsStoredPosition() {
        let position = Position2D(latitude: 51.5, longitude: -1.0)
        let origin = GeodeticOrigin(position)
        
        XCTAssertEqual(origin.position.latitude.decimalDegrees, 51.5, accuracy: 0.0001)
        XCTAssertEqual(origin.position.longitude.decimalDegrees, -1.0, accuracy: 0.0001)
    }
}
