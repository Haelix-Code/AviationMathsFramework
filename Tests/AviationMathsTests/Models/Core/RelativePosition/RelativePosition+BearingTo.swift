import XCTest
@testable import AviationMaths

final class RelativePositionBearingtoTests: XCTestCase {

    func testBearingTo_usesAviationConvention() {
        let origin = RelativePosition(x: .init(meters: 0), y: .init(meters: 0))

        // +Y is North => bearing 0
        let north = RelativePosition(x: .init(meters: 0), y: .init(meters: 10))
        XCTAssertEqual(origin.bearing(to: north).degrees, 0, accuracy: 1e-12)

        // +X is East => bearing 90
        let east = RelativePosition(x: .init(meters: 10), y: .init(meters: 0))
        XCTAssertEqual(origin.bearing(to: east).degrees, 90, accuracy: 1e-12)

        // -Y is South => 180
        let south = RelativePosition(x: .init(meters: 0), y: .init(meters: -10))
        XCTAssertEqual(origin.bearing(to: south).degrees, 180, accuracy: 1e-12)

        // -X is West => 270
        let west = RelativePosition(x: .init(meters: -10), y: .init(meters: 0))
        XCTAssertEqual(origin.bearing(to: west).degrees, 270, accuracy: 1e-12)
    }

}
