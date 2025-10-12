import XCTest
@testable import AviationMaths

final class UnitAltitudeTests: XCTestCase {
    private let standardContext: AltitudeContext = .standardISA
    
    // MARK: Conversions Between References
    // From AGL
    func testAGLtoAMSL_SeaLevel() throws {
        let thisAltitude = Altitude(feet: 1000, reference: .agl, context: .standardISA)
        
        XCTAssertEqual(thisAltitude.amsl.feet, 1000)
    }
    
    func testAGLtoAMSL() throws {
        let thisAltitude = Altitude(feet: 1000, reference: .agl, context: .init(groundElevation: .init(feet: 5000)))
        
        XCTAssertEqual(thisAltitude.amsl.feet, 6000)
    }
    
    func testAGLtoPA() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .agl, context: .init(groundElevation: .init(feet: 500), qnh: .init(pascals: 101000)))

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, 15579.4, accuracy: 0.1)
    }
    
    func testAGLtoGeopotential() throws {
        
    }
    
    
    // From AMSL
    func testAMSLtoAGL_SeaLevel() throws {
        let thisAltitude = Altitude(feet: 1000, reference: .amsl, context: .init(groundElevation: .init(feet: 1000)))
        
        XCTAssertEqual(thisAltitude.agl.feet, 0, accuracy: 0.01)
    }
    
    func testAMSLtoAGL() throws {
        let thisAltitude = Altitude(feet: 6000, reference: .amsl, context: .init(groundElevation: .init(feet: 5000)))
        
        XCTAssertEqual(thisAltitude.agl.feet, 1000, accuracy: 0.01)
    }
    
    func testAMSLtoPA_Standard() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .standardISA)

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, thisAltitude.amsl.feet, accuracy: 0.0001)
    }
    
    func testAMSLtoPA() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .init(groundElevation: .init(feet: 520), qnh: .init(pascals: 101000)))

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, 15079.7, accuracy: 0.1)
    }
    
    func testAMSLtoPANoElev() throws {
        let context = AltitudeContext(
            qnh: .init(hectopascals: 1010)
        )
        
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: context)
        
        XCTAssertEqual(thisAltitude.pressureAltitude.feet, 15079.7, accuracy: 0.1)
    }
    
    func testAMSLtoGeopotential() throws {
        
    }
    
    // From PA
    func testPAtoAGL_Standard() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .init(groundElevation: .init(feet: 5000)))

        XCTAssertEqual(thisAltitude.agl.feet, 10000, accuracy: 0.0001)

    }
    
    func testPAtoAGL() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .pressureAltitude, context: .init(groundElevation: .init(feet: 520), qnh: .init(pascals: 101000)))

        XCTAssertEqual(thisAltitude.agl.feet, 14400.2, accuracy: 0.1)

    }
    
    func testPAtoAMSL_Standard() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .pressureAltitude, context: .standardISA)

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, thisAltitude.amsl.feet, accuracy: 0.0001)
    }
    
    func testPAtoAMSL() throws {
        let thisAltitude = Altitude(feet: 15000, reference: .amsl, context: .init(groundElevation: .init(feet: 520), qnh: .init(pascals: 99000)))

        XCTAssertEqual(thisAltitude.pressureAltitude.feet, 15574.9, accuracy: 0.1)
    }
    
    func testPAtoGeopotential() throws {
        
    }
    
    // From DA
    func testGeopotentialtoAGL(){
        
    }
    
    func testGeopotentialtoAMSL() {
        
    }
    
    func testGeopotentialtoPA() {
        
    }

    // Test Reference Conversion Methods
    func testLengthUnits() throws {
        let altitude = Altitude(meters: 1000, reference: .agl, context: standardContext)
        XCTAssertEqual(altitude.agl.meters, 1000)
        XCTAssertEqual(altitude.agl.feet, 3280.84, accuracy: 0.1)
    }
}
