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
        XCTAssertEqual(dms.formatted(direction: "N", secondsPrecision: 2), "05°07'09.12\"N")
        XCTAssertEqual(dms.formatted(direction: "E", isLongitude: true), "005°07'09.1\"E")
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
        XCTAssertEqual(ddm.formatted(direction: "S"), "05°07.12'S")
        XCTAssertEqual(ddm.formatted(direction: "W", isLongitude: true, minutesPrecision: 3), "005°07.123'W")
    }

    func testDMSInitFromDecimalDegrees_RollsOverSecondsAndMinutes() {
        let dms = DegreesMinutesSeconds(decimalDegrees: 10.1)

        XCTAssertEqual(dms.degrees, 10)
        XCTAssertEqual(dms.minutes, 6, "0.1\u{00B0} is exactly 6 minutes; seconds must not round up into a 60th minute")
        XCTAssertEqual(dms.seconds, 0, accuracy: 0.01)
    }

    func testLatitudeAndLongitudeDescription_CarryMinutesIntoDegrees() {
        XCTAssertEqual(Latitude(decimalDegrees: 51.99999).description, "52°00.00'N")
        XCTAssertEqual(Longitude(decimalDegrees: -0.9999999).description, "001°00.00'W")
    }

    func testDMSFormatted_CarriesSecondsAtDisplayedPrecision() {
        let dms = DegreesMinutesSeconds(degrees: 10, minutes: 59, seconds: 59.97)

        XCTAssertEqual(dms.formatted(direction: "N"), "11°00'00.0\"N")
        XCTAssertEqual(DegreesMinutesSeconds(degrees: 10, minutes: 59, seconds: 59.996).description, "11° 0' 0.00\"")
    }

    func testDDMFormatted_CarriesMinutesAtDisplayedPrecision() {
        let ddm = DegreesDecimalMinutes(degrees: 12, minutes: 59.9996)

        XCTAssertEqual(ddm.formatted(minutesPrecision: 2), "13° 0.00'")
        XCTAssertEqual(ddm.description, "13° 0.000'")
    }

    func testDMSInitFromDecimalDegrees_KeepsFullPrecision() {
        let dms = DegreesMinutesSeconds(decimalDegrees: 51.123456789)

        XCTAssertEqual(dms.asDecimalDegrees, 51.123456789, accuracy: 1e-10)
    }

    func testCrossConversionConsistency() {
        let dms = DegreesMinutesSeconds(degrees: 10, minutes: 30, seconds: 30)
        let ddm = dms.asDegreesDecimalMinutes
        let backToDMS = ddm.asDegreesMinutesSeconds

        XCTAssertEqual(dms.asDecimalDegrees, ddm.asDecimalDegrees, accuracy: 1e-6)
        XCTAssertEqual(backToDMS.asDecimalDegrees, dms.asDecimalDegrees, accuracy: 1e-6)
    }
}
