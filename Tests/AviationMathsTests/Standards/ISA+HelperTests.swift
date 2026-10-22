import XCTest
@testable import AviationMaths

final class ISAHelperTests: XCTestCase {

    func testDensityFromPressureAndTemperature_Standard() {
        let pressure = Measurement(value: 101325, unit: UnitPressure.pascals)
        let temperature = Measurement(value: 288.15, unit: UnitTemperature.kelvin)
        let density = ISA.densityFromPressureAndTemperature(pressure: pressure, temperature: temperature)
        XCTAssertEqual(density.value, 1.225, accuracy: 0.01)
    }

    func testDensityFromPressureAndTemperature() {
        let pressure = Measurement(value: 26436, unit: UnitPressure.pascals)
        let temperature = Measurement(value: 233.15, unit: UnitTemperature.kelvin)
        let density = ISA.densityFromPressureAndTemperature(pressure: pressure, temperature: temperature)
        XCTAssertEqual(density.value, 0.39501, accuracy: 0.01)
    }

    func testSpeedOfSoundFromTemperature() {
        let temperature = Measurement(value: 288.15, unit: UnitTemperature.kelvin)
        let speedOfSound = ISA.speedOfSoundFromTemperature(temperature: temperature)
        XCTAssertEqual(speedOfSound.value, 340.30, accuracy: 0.01)
    }

    func testSpeedOfSoundWithExtremeTemperatures() {
        let temperature = Measurement(value: -40, unit: UnitTemperature.celsius)
        let speedOfSound = ISA.speedOfSoundFromTemperature(temperature: temperature)

        XCTAssertEqual(speedOfSound.value, 306.100, accuracy: 0.001)
    }

    func testPressureFromQNHAndAMSL_atSeaLevelEqualsQNH() {
        let qnh = Measurement<UnitPressure>(hectopascals: 1013.25)
        let p = ISA.pressureFromQNHAndAMSL(qnh: qnh, amsl: .init(meters: 0))

        XCTAssertEqual(p.hectopascals, qnh.hectopascals, accuracy: 1e-6)
    }

}
