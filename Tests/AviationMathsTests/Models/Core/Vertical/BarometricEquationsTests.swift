import XCTest
@testable import AviationMaths

final class BarometricEquationsTests: XCTestCase {
    // MARK: Conversions Between References
    func testConvertVerticalDistanceMetersToPressurePa() throws {
        let pressureAtAltitude = BarometricEquations.pressureFromAltitude(altitude: .init(meters: 1000), referencePressure: .init(pascals: 101325))
        
        XCTAssertEqual(pressureAtAltitude, 89874.75, accuracy: 0.01)
    }
    
    func testConvertVerticalDistanceMetersQNHToPressurePa() throws {
        let pressureAtAltitude = BarometricEquations.pressureFromAltitude(altitude: .init(meters: 5000), referencePressure: .init(pascals: 101000))
        
        XCTAssertEqual(pressureAtAltitude, 53847.22, accuracy: 0.01)
    }
    
//    
//    it('should convert Altitude and QNH to pressure', () => {
//      expect(service.convertVerticalDistanceMetersToPressurePa(1000, 101325).toFixed(1)).toEqual('89868.9');
//      expect(service.convertVerticalDistanceMetersToPressurePa(5000, 101325).toFixed(1)).toEqual('54002.0');
//      expect(service.convertVerticalDistanceMetersToPressurePa(10000, 101325).toFixed(1)).toEqual('26417.6');
//      expect(service.convertVerticalDistanceMetersToPressurePa(5000, 101000).toFixed(1)).toEqual('53828.8');
//    });

}
