import XCTest
@testable import AviationMaths

final class BarometricEquationsTests: XCTestCase {
    func testConvertVerticalDistanceMetersToPressurePaISA() throws {
        let pressureAtAltitude = BarometricEquations.pressureFromAltitude(altitude: .init(meters: 1000))
        
        XCTAssertEqual(pressureAtAltitude.pascals, 89874.75, accuracy: 0.01)
    }
    
    func testConvertVerticalDistanceMetersAndQNHToPressurePa() throws {
        let pressureAtAltitude = BarometricEquations.pressureFromAltitude(altitude: .init(meters: 5000), referencePressure: .init(pascals: 101000))
        
        XCTAssertEqual(pressureAtAltitude.pascals, 53847.22, accuracy: 0.01)
    }
    
    func testconvertVerticalPressurePaToAltitudeMeters_ZERO() throws {
        let pressure: Measurement<UnitPressure> = .init(pascals: 101325)
        let referencePressure: Measurement<UnitPressure> = .init(hectopascals: 1013.25)
        
        let altitude = BarometricEquations.altitudeFromPressure(pressure: pressure, referencePressure: referencePressure)
        
        XCTAssertEqual(altitude.meters, 0)
    }
    
    func testConvertVerticalPressurePaToAltitudeMetersISA() throws {
        let pressure: Measurement<UnitPressure> = .init(pascals: 26436)
        
        let altitude = BarometricEquations.altitudeFromPressure(pressure: pressure)
        
        XCTAssertEqual(altitude.meters, 10000, accuracy: 1)
    }
    
    func testconvertVerticalPressurePaToAltitudeMeters() throws {
        let pressure: Measurement<UnitPressure> = .init(pascals: 95325)
        let referencePressure: Measurement<UnitPressure> = .init(hectopascals: 990)
        
        let altitude = BarometricEquations.altitudeFromPressure(pressure: pressure, referencePressure: referencePressure)
        
        XCTAssertEqual(altitude.meters, 317.9, accuracy: 1)
    }
    
    func testconvertVerticalPressurePaAndQNHToAltitudeMeters() throws {
        let pressure: Measurement<UnitPressure> = .init(pascals: 50000)
        let referencePressure: Measurement<UnitPressure> = .init(hectopascals: 1010)
        
        let altitude = BarometricEquations.altitudeFromPressure(pressure: pressure, referencePressure: referencePressure)
        
        XCTAssertEqual(altitude.meters, 5550.8, accuracy: 1)
    }
    
}
