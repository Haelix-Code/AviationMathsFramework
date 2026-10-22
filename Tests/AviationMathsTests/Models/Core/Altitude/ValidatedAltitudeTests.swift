import XCTest
@testable import AviationMaths

final class ValidatedAltitudeContextTests: XCTestCase {
    
    func test_init_withCompleteContext_succeeds() {
        let ctx = AltitudeContext(
            groundElevation: .init(value: 500, unit: .feet),
            qnh: .init(value: 1013.25, unit: .hectopascals),
            surfaceTemperature: .init(value: 12, unit: .celsius), seaLevelTemperature: .init(value: 15, unit: .celsius),
            lapseRate: 0.0065
        )
        
        let validated = ValidatedAltitudeContext(ctx)
        
        XCTAssertEqual(validated.groundElevation.converted(to: .feet).value, 500, accuracy: 0.01)
        XCTAssertEqual(validated.qnh.converted(to: .hectopascals).value, 1013.25, accuracy: 0.01)
    }
    
    func test_isComplete_returnsTrueForCompleteContext() {
        let ctx = AltitudeContext(
            groundElevation: .init(value: 500, unit: .feet),
            qnh: .init(value: 1013.25, unit: .hectopascals),
            surfaceTemperature: .init(value: 12, unit: .celsius), seaLevelTemperature: .init(value: 15, unit: .celsius),
            lapseRate: 0.0065
        )
        
        XCTAssertTrue(ctx.isComplete)
    }
    
    func test_isComplete_returnsFalseForIncompleteContext() {
        let ctx = AltitudeContext(
            groundElevation: .init(value: 500, unit: .feet),
            qnh: nil,
            seaLevelTemperature: .init(value: 15, unit: .celsius),
            lapseRate: 0.0065
        )
        
        XCTAssertFalse(ctx.isComplete)
    }
    
    func test_validated_returnsNilForIncompleteContext() {
        let ctx = AltitudeContext(
            groundElevation: .init(value: 500, unit: .feet),
            qnh: nil,
            seaLevelTemperature: nil,
            lapseRate: nil
        )
        
        XCTAssertNil(ctx.validated)
    }
}

final class ValidatedAltitudeTests: XCTestCase {
    
    private var validatedContext: ValidatedAltitudeContext {
        ValidatedAltitudeContext(AltitudeContext(
            groundElevation: .init(value: 500, unit: .feet),
            qnh: .init(value: 1013.25, unit: .hectopascals),
            surfaceTemperature: .init(value: 12, unit: .celsius), seaLevelTemperature: .init(value: 15, unit: .celsius),
            lapseRate: 0.0065
        ))
    }
    
    func test_init_fromValidatedContext() {
        let altitude = ValidatedAltitude(
            value: .init(value: 10000, unit: .feet),
            reference: .pressureAltitude,
            context: validatedContext
        )
        
        XCTAssertEqual(altitude.value.converted(to: .feet).value, 10000, accuracy: 0.01)
        XCTAssertEqual(altitude.reference, .pressureAltitude)
    }
    
    func test_safeAccessors_doNotCrash() {
        let altitude = ValidatedAltitude(
            value: .init(value: 10000, unit: .feet),
            reference: .pressureAltitude,
            context: validatedContext
        )
        
        // These would crash on raw Altitude with incomplete context
        let _ = altitude.agl
        let _ = altitude.amsl
        let _ = altitude.pressureAltitude
        let _ = altitude.trueAltitude
    }
    
    func test_valueIn_returnsCorrectReference() {
        let altitude = ValidatedAltitude(
            value: .init(value: 10000, unit: .feet),
            reference: .pressureAltitude,
            context: validatedContext
        )
        
        let pa = altitude.value(in: .pressureAltitude)
        XCTAssertEqual(pa.converted(to: .feet).value, 10000, accuracy: 0.01)
    }
    
    func test_converted_changesReference() {
        let altitude = ValidatedAltitude(
            value: .init(value: 10000, unit: .feet),
            reference: .pressureAltitude,
            context: validatedContext
        )
        
        let asAMSL = altitude.converted(to: .amsl)
        
        XCTAssertEqual(asAMSL.reference, .amsl)
    }
    
    func test_isBelow_ordersCorrectly() {
        let low = ValidatedAltitude(
            value: .init(value: 5000, unit: .feet),
            reference: .amsl,
            context: validatedContext
        )
        let high = ValidatedAltitude(
            value: .init(value: 15000, unit: .feet),
            reference: .amsl,
            context: validatedContext
        )
        
        XCTAssertTrue(low.isBelow(high))
        XCTAssertFalse(high.isBelow(low))
        XCTAssertFalse(low.isBelow(low))
    }

    func test_isSameLevel_acrossReferences() {
        let pressureAltitude = ValidatedAltitude(
            value: .init(value: 10000, unit: .feet),
            reference: .pressureAltitude,
            context: validatedContext
        )
        let asAMSL = pressureAltitude.converted(to: .amsl)

        XCTAssertNotEqual(pressureAltitude, asAMSL)
        XCTAssertTrue(pressureAltitude.isSameLevel(as: asAMSL, tolerance: .init(meters: 1e-6)))
        XCTAssertFalse(pressureAltitude.isSameLevel(
            as: ValidatedAltitude(value: .init(value: 10001, unit: .feet), reference: .pressureAltitude, context: validatedContext),
            tolerance: .init(meters: 1e-6)
        ))
    }
    
    func test_altitude_validated_returnsNilForIncompleteContext() {
        let incompleteCtx = AltitudeContext(
            groundElevation: .init(value: 500, unit: .feet),
            qnh: nil,
            seaLevelTemperature: nil,
            lapseRate: nil
        )
        let altitude = Altitude(
            value: .init(value: 10000, unit: .feet),
            reference: .amsl,
            context: incompleteCtx
        )
        
        XCTAssertNil(altitude.validated)
    }
}
