import XCTest
@testable import AviationMaths

final class WindTests: XCTestCase {
    func test_init_createsWindWithCorrectValues() {
        let wind = Wind(
            altitude: .init(feet: 5000),
            direction: .init(degrees: 270),
            speed: .init(knots: 25)
        )
        XCTAssertEqual(wind.altitude.feet, 5000)
        XCTAssertEqual(wind.direction.degrees, 270)
        XCTAssertEqual(wind.speed.knots, 25)
    }

    func test_components_withDirectHeadwind_returnsFullHeadwindZeroCrosswind() {
        let wind = Wind(
            altitude: .init(feet: 5000),
            direction: .init(degrees: 360),
            speed: .init(knots: 20)
        )
        let track = Measurement<UnitAngle>(degrees: 360)
        let components = wind.components(relativeTo: track)

        XCTAssertEqual(components.headwind.knots, 20, accuracy: 0.01)
        XCTAssertEqual(components.crosswind.knots, 0, accuracy: 0.01)
    }

    func test_components_withDirectTailwind_returnsNegativeHeadwindZeroCrosswind() {
        let wind = Wind(
            altitude: .init(feet: 5000),
            direction: .init(degrees: 360),
            speed: .init(knots: 20)
        )
        let track = Measurement<UnitAngle>(degrees: 180)
        let components = wind.components(relativeTo: track)

        XCTAssertEqual(components.headwind.knots, -20, accuracy: 0.01)
        XCTAssertEqual(components.crosswind.knots, 0, accuracy: 0.01)
    }

    func test_components_withDirectRightCrosswind_returnsZeroHeadwindPositiveCrosswind() {
        let wind = Wind(
            altitude: .init(feet: 5000),
            direction: .init(degrees: 90),
            speed: .init(knots: 15)
        )
        let track = Measurement<UnitAngle>(degrees: 360)
        let components = wind.components(relativeTo: track)

        XCTAssertEqual(components.headwind.knots, 0, accuracy: 0.01)
        XCTAssertEqual(components.crosswind.knots, 15, accuracy: 0.01)
    }

    func test_components_with45DegreeWind_returnsBothComponents() {
        let wind = Wind(
            altitude: .init(feet: 5000),
            direction: .init(degrees: 45),
            speed: .init(knots: 20)
        )
        let track = Measurement<UnitAngle>(degrees: 360)
        let components = wind.components(relativeTo: track)
        let expectedComponent = 20.0 / sqrt(2.0)
        XCTAssertEqual(components.headwind.knots, expectedComponent, accuracy: 0.01)
        XCTAssertEqual(components.crosswind.knots, expectedComponent, accuracy: 0.01)
    }

    func test_groundSpeed_withHeadwind_reducesGroundSpeed() {
        let wind = Wind(
            altitude: .init(feet: 10000),
            direction: .init(degrees: 360),
            speed: .init(knots: 30)
        )
        let groundSpeed = wind.groundSpeed(
            trueAirspeed: .init(knots: 150),
            track: .init(degrees: 360)
        )

        XCTAssertEqual(groundSpeed.knots, 120, accuracy: 0.1)
    }

    func test_groundSpeed_withPureCrosswind_doesNotAffectGroundSpeed() {
        let wind = Wind(
            altitude: .init(feet: 10000),
            direction: .init(degrees: 90),
            speed: .init(knots: 25)
        )
        let groundSpeed = wind.groundSpeed(
            trueAirspeed: .init(knots: 150),
            track: .init(degrees: 360)  // Flying north (perpendicular to wind)
        )

        XCTAssertEqual(groundSpeed.knots, 150, accuracy: 0.1)
    }
}
