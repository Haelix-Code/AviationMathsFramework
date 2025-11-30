import XCTest
import Foundation
@testable import AviationMaths

final class PolarVectorLengthTests: XCTestCase {
    
    func testLengthProperty() {
        let v = LengthPolar(bearing: .init(degrees: 45), magnitude: .init(meters: 5))
        
        XCTAssertEqual(v.length.meters, 5, accuracy: 0.0001)
        XCTAssertEqual(v.length.unit, UnitLength.meters)
    }
    
    func testMagnitudeAndLengthAreEquivalent() {
        let v = LengthPolar(bearing: .init(degrees: 90), magnitude: .init(meters: 100))
        
        XCTAssertEqual(v.length.meters, v.magnitude.meters, accuracy: 0.0001)
    }


    func testLengthCartesianVector_North() {
        let v = LengthPolar(bearing: .init(degrees: 0), magnitude: .init(meters: 10))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, 0, accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, 10, accuracy: 0.0001)
    }
    
    func testLengthCartesianVector_East() {
        let v = LengthPolar(bearing: .init(degrees: 90), magnitude: .init(meters: 10))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, 10, accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 0.0001)
    }
    
    func testLengthCartesianVector_South() {
        let v = LengthPolar(bearing: .init(degrees: 180), magnitude: .init(meters: 10))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, 0, accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, -10, accuracy: 0.0001)
    }
    
    func testLengthCartesianVector_West() {
        let v = LengthPolar(bearing: .init(degrees: 270), magnitude: .init(meters: 10))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, -10, accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 0.0001)
    }

    func testLengthCartesianVector_NorthEast() {
        let v = LengthPolar(bearing: .init(degrees: 45), magnitude: .init(meters: 1))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, sqrt(0.5), accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, sqrt(0.5), accuracy: 0.0001)
    }
    
    func testLengthCartesianVector_SouthEast() {
        let v = LengthPolar(bearing: .init(degrees: 135), magnitude: .init(meters: 1))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, sqrt(0.5), accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, -sqrt(0.5), accuracy: 0.0001)
    }
    
    func testLengthCartesianVector_SouthWest() {
        let v = LengthPolar(bearing: .init(degrees: 225), magnitude: .init(meters: 1))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, -sqrt(0.5), accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, -sqrt(0.5), accuracy: 0.0001)
    }
    
    func testLengthCartesianVector_NorthWest() {
        let v = LengthPolar(bearing: .init(degrees: 315), magnitude: .init(meters: 1))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, -sqrt(0.5), accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, sqrt(0.5), accuracy: 0.0001)
    }

    func testRoundTrip_AllCardinals() {
        let bearings: [Double] = [0, 90, 180, 270]
        
        for bearing in bearings {
            let original = LengthPolar(bearing: .init(degrees: bearing), magnitude: .init(meters: 100))
            let cart = original.lengthCartesianVector
            let recovered = cart.asPolar
            
            XCTAssertEqual(recovered.bearing.degrees, bearing, accuracy: 0.0001,
                          "Failed round-trip for bearing \(bearing)")
            XCTAssertEqual(recovered.magnitude.meters, 100, accuracy: 0.0001)
        }
    }
    
    func testRoundTrip_AllQuadrants() {
        let bearings: [Double] = [45, 135, 225, 315]
        
        for bearing in bearings {
            let original = LengthPolar(bearing: .init(degrees: bearing), magnitude: .init(meters: 50))
            let cart = original.lengthCartesianVector
            let recovered = cart.asPolar
            
            XCTAssertEqual(recovered.bearing.degrees, bearing, accuracy: 0.0001,
                          "Failed round-trip for bearing \(bearing)")
        }
    }
    
    func testRoundTrip_IntermediateBearings() {
        let bearings: [Double] = [15, 30, 60, 75, 105, 120, 150, 165, 195, 210, 240, 255, 285, 300, 330, 345]
        
        for bearing in bearings {
            let original = LengthPolar(bearing: .init(degrees: bearing), magnitude: .init(meters: 1000))
            let cart = original.lengthCartesianVector
            let recovered = cart.asPolar
            
            XCTAssertEqual(recovered.bearing.degrees, bearing, accuracy: 0.001,
                          "Failed round-trip for bearing \(bearing)")
        }
    }

    func testZeroMagnitude() {
        let v = LengthPolar(bearing: .init(degrees: 123), magnitude: .init(meters: 0))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, 0, accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 0.0001)
        XCTAssertEqual(v.length.meters, 0, accuracy: 0.0001)
    }
    
    func testBearingNormalization() {
        // 450° should behave like 90°
        let v = LengthPolar(bearing: .init(degrees: 450), magnitude: .init(meters: 10))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, 10, accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 0.0001)
    }
    
    func testNegativeBearing() {
        // -90° should behave like 270° (West)
        let v = LengthPolar(bearing: .init(degrees: -90), magnitude: .init(meters: 10))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, -10, accuracy: 0.0001)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 0.0001)
    }

    func testDifferentUnits_Feet() {
        let v = LengthPolar(bearing: .init(degrees: 0), magnitude: .init(feet: 1000))
        
        XCTAssertEqual(v.length.feet, 1000, accuracy: 0.0001)
        XCTAssertEqual(v.length.meters, 304.8, accuracy: 0.1)
    }
    
    func testDifferentUnits_NauticalMiles() {
        let v = LengthPolar(bearing: .init(degrees: 90), magnitude: .init(value: 1, unit: .nauticalMiles))
        let cart = v.lengthCartesianVector
        
        XCTAssertEqual(cart.x.meters, 1852, accuracy: 0.1)
        XCTAssertEqual(cart.y.meters, 0, accuracy: 0.1)
    }

    func testNavigationOffset() {
        // Aircraft needs to fly 5nm on bearing 045 to reach waypoint
        let offset = LengthPolar(
            bearing: .init(degrees: 45),
            magnitude: .init(value: 5, unit: .nauticalMiles)
        )
        let cart = offset.lengthCartesianVector
        
        // Should be ~3.54nm East and ~3.54nm North
        let expectedComponent = 5 * sqrt(0.5)
        XCTAssertEqual(cart.x.converted(to: .nauticalMiles).value, expectedComponent, accuracy: 0.01)
        XCTAssertEqual(cart.y.converted(to: .nauticalMiles).value, expectedComponent, accuracy: 0.01)
    }
}
