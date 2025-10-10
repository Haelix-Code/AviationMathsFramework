import XCTest
@testable import AviationMaths

final class UnitAltitudeTests: XCTestCase {
    private let standardContext: AltitudeContext = .standardISA
    
    private let elevatedContext = AltitudeContext(
        groundElevation: Measurement(meters: 1000),
        qnh: Measurement(hectopascals: 1013.25),
        surfaceTemperature: Measurement(celsius: 15),
        lapseRate: ISA.lapseRate(at: .init(meters: 0))
    )
    
    
    // MARK: Conversions Between References
    func testAGLtoAMSL_SeaLevel() throws {
        let thisAltitude = Altitude(feet: 1000, reference: .agl, context: .standardISA)
        
        XCTAssertEqual(thisAltitude.amsl.feet, 1000)
    }
    
    func testAGLtoAMSL() throws {
        let thisAltitude = Altitude(feet: 1000, reference: .agl, context: .init(groundElevation: .init(feet: 5000)))
        
        XCTAssertEqual(thisAltitude.amsl.feet, 6000)
    }
    
    func testAMSLtoAGL_SeaLevel() throws {
        let thisAltitude = Altitude(feet: 1000, reference: .amsl, context: .init(groundElevation: .init(feet: 1000)))
        
        XCTAssertEqual(thisAltitude.agl.feet, 0, accuracy: 0.01)
    }
    
    func testAMSLtoAGL() throws {
        let thisAltitude = Altitude(feet: 6000, reference: .amsl, context: .init(groundElevation: .init(feet: 5000)))
        
        XCTAssertEqual(thisAltitude.agl.feet, 1000, accuracy: 0.01)
    }
    
    func testAGLtoPA() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .agl, context: .init(groundElevation: .init(feet: 520), qnh: .init(pascals: 101000)))

        XCTAssertEqual(thisAltitude.pa.feet, 15599.4, accuracy: 0.1)
    }
    
    func testAMSLtoPA_Standard() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .standardISA)

        XCTAssertEqual(thisAltitude.pa.feet, thisAltitude.amsl.feet, accuracy: 0.0001)
    }
    
    func testAMSLtoPA() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .init(groundElevation: .init(feet: 520), qnh: .init(pascals: 101000)))

        XCTAssertEqual(thisAltitude.pa.feet, 15079.7, accuracy: 0.1)
    }
    
    func testPAtoAMSL_Standard() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .standardISA)

        XCTAssertEqual(thisAltitude.pa.feet, thisAltitude.amsl.feet, accuracy: 0.0001)
    }
    
    func testPAtoAMSL() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .init(groundElevation: .init(feet: 520), qnh: .init(pascals: 99000)))

        XCTAssertEqual(thisAltitude.pa.feet, 15574.9, accuracy: 0.1)
    }
    
    // Test Reference Conversion Methods
    func testLengthUnits() throws {
        let altitude = Altitude(meters: 1000, reference: .agl, context: standardContext)
        XCTAssertEqual(altitude.agl.meters, 1000)
        XCTAssertEqual(altitude.agl.feet, 3280.84, accuracy: 0.1)
    }
}
