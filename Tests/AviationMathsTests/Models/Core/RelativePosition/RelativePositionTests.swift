import XCTest
@testable import AviationMaths

final class RelativePositionTests: XCTestCase {

    func testInitWithAngleAndRange() {
        let angle = Measurement(value: 90, unit: UnitAngle.degrees)
        let range = Measurement(value: 10, unit: UnitLength.meters)

        let position = RelativePosition(angle: angle, range: range)

        XCTAssertEqual(position.angle, angle)
        XCTAssertEqual(position.range, range)
    }

    func testInitWithXY() {
        let x = Measurement(value: 3, unit: UnitLength.meters)
        let y = Measurement(value: 4, unit: UnitLength.meters)

        let position = RelativePosition(x: x, y: y)

        XCTAssertEqual(position.x, x)
        XCTAssertEqual(position.y, y)

        XCTAssertEqual(position.range.value, 5, accuracy: 0.0001)
    }

    func testInitWithVector2D() {
        let vector = Vector2D(x: Measurement(value: 1, unit: UnitLength.meters),
                              y: Measurement(value: 1, unit: UnitLength.meters))

        let position = RelativePosition(vector2D: vector)

        XCTAssertEqual(position.vector2D.x, vector.x)
        XCTAssertEqual(position.vector2D.y, vector.y)
    }

    func testPerpendicularAngles() {
        let pos = RelativePosition(angle: Measurement(value: 0, unit: UnitAngle.degrees),
                                   range: Measurement(value: 1, unit: UnitLength.meters))

        let perpendiculars = pos.perpendicularAngles
        XCTAssertEqual(perpendiculars.count, 2)
    }

}
