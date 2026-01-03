import XCTest
@testable import AviationMaths

final class CoordinateFormatsTests: XCTestCase {

    func testDMSAsDecimalDegrees() {
        let dms = DegreesMinutesSeconds(degrees: 10, minutes: 30, seconds: 30)
        let decimal = dms.asDecimalDegrees
        XCTAssertEqual(decimal, 10.508333, accuracy: 1e-6)
    }

    func testDMSInitFromDecimalDegrees() {
        let dms = DegreesMinutesSeconds(decimalDegrees: 10.508333)
        XCTAssertEqual(dms.degrees, 10)
        XCTAssertEqual(dms.minutes, 30)
        XCTAssertEqual(dms.seconds, 30, accuracy: 1e-2)
    }

    func testDMSDescriptionAndFormatted() {
        let dms = DegreesMinutesSeconds(degrees: 12, minutes: 34, seconds: 56.789)
        XCTAssertEqual(dms.description, "12° 34' 56.79\"")
        XCTAssertEqual(dms.formatted(secondsPrecision: 1), "12° 34' 56.8\"")
    }

    func testDMSFormattedWithDirection() {
        let dms = DegreesMinutesSeconds(degrees: 5, minutes: 7, seconds: 9.12)
        XCTAssertEqual(dms.formatted(direction: "N"), "05°07'09.12\"N")
        XCTAssertEqual(dms.formatted(direction: "E", isLongitude: true), "005°07'09.12\"E")
    }

    func testDDMAsDecimalDegrees() {
        let ddm = DegreesDecimalMinutes(degrees: 10, minutes: 30.0)
        let decimal = ddm.asDecimalDegrees
        XCTAssertEqual(decimal, 10.5, accuracy: 1e-6)
    }

    func testDDMInitFromDecimalDegrees() {
        let ddm = DegreesDecimalMinutes(decimalDegrees: 10.5)
        XCTAssertEqual(ddm.degrees, 10)
        XCTAssertEqual(ddm.minutes, 30.0, accuracy: 1e-6)
    }

    func testDDMDescriptionAndFormatted() {
        let ddm = DegreesDecimalMinutes(degrees: 12, minutes: 34.5678)
        XCTAssertEqual(ddm.description, "12° 34.568'")
        XCTAssertEqual(ddm.formatted(minutesPrecision: 2), "12° 34.57'")
    }

    func testDDMFormattedWithDirection() {
        let ddm = DegreesDecimalMinutes(degrees: 5, minutes: 7.123)
        XCTAssertEqual(ddm.formatted(direction: "S"), "05°07.123'S")
        XCTAssertEqual(ddm.formatted(direction: "W", isLongitude: true), "005°07.123'W")
    }

    func testCrossConversionConsistency() {
        let dms = DegreesMinutesSeconds(degrees: 10, minutes: 30, seconds: 30)
        let ddm = dms.asDegreesDecimalMinutes
        let backToDMS = ddm.asDegreesMinutesSeconds

        XCTAssertEqual(dms.asDecimalDegrees, ddm.asDecimalDegrees, accuracy: 1e-6)
        XCTAssertEqual(backToDMS.asDecimalDegrees, dms.asDecimalDegrees, accuracy: 1e-6)
    }
}
