import Foundation

public struct DegreesMinutesSeconds: Equatable, Hashable, Codable, Sendable {
    public let degrees: Int
    public let minutes: Int
    public let seconds: Double

    public init(degrees: Int, minutes: Int, seconds: Double) {
        self.degrees = abs(degrees)
        self.minutes = abs(minutes)
        self.seconds = abs(seconds)
    }

    public var asDecimalDegrees: Double {
        Double(degrees) + (Double(minutes) / 60.0) + (seconds / 3600.0)
    }

    public init(decimalDegrees: Double) {
        let unsigned = abs(decimalDegrees)
        var deg = Int(unsigned)
        let minutesDecimal = (unsigned - Double(deg)) * 60.0
        var min = Int(minutesDecimal)
        var sec = (minutesDecimal - Double(min)) * 60.0

        // Snap floating-point noise before carrying: seconds can land just under
        // 60 (e.g. 59.999999999987), which must still roll over into minutes (and
        // minutes into degrees). 1e-9" keeps the stored value's real precision;
        // rounding for display happens in the formatters.
        sec = (sec * 1e9).rounded() / 1e9
        if sec >= 60 {
            sec -= 60
            min += 1
        }
        if min >= 60 {
            min -= 60
            deg += 1
        }

        self.init(degrees: deg, minutes: min, seconds: sec)
    }
}

public struct DegreesDecimalMinutes: Equatable, Hashable, Codable, Sendable {
    public let degrees: Int
    public let minutes: Double

    public init(degrees: Int, minutes: Double) {
        self.degrees = abs(degrees)
        self.minutes = abs(minutes)
    }

    public var asDecimalDegrees: Double {
        Double(degrees) + (minutes / 60.0)
    }

    public init(decimalDegrees: Double) {
        let unsigned = abs(decimalDegrees)
        let deg = Int(unsigned)
        let min = (unsigned - Double(deg)) * 60.0

        self.init(degrees: deg, minutes: min)
    }
}

// swiftlint:disable large_tuple
extension DegreesMinutesSeconds {
    /// The components to display at `precision` decimal places of a second: if the
    /// seconds would round to 60, they carry into the minute (and 60' into the degree).
    private func displayed(secondsPrecision precision: Int) -> (degrees: Int, minutes: Int, seconds: Double) {
        let scale = pow(10, Double(precision))
        guard (seconds * scale).rounded() / scale >= 60 else { return (degrees, minutes, seconds) }
        return minutes + 1 >= 60 ? (degrees + 1, 0, 0) : (degrees, minutes + 1, 0)
    }
}
// swiftlint:enable large_tuple

extension DegreesDecimalMinutes {
    /// The components to display at `precision` decimal places of a minute: if the
    /// minutes would round to 60, they carry into the degree.
    private func displayed(minutesPrecision precision: Int) -> (degrees: Int, minutes: Double) {
        let scale = pow(10, Double(precision))
        guard (minutes * scale).rounded() / scale >= 60 else { return (degrees, minutes) }
        return (degrees + 1, 0)
    }
}

extension DegreesMinutesSeconds: CustomStringConvertible {
    public var description: String {
        formatted(secondsPrecision: 2)
    }

    public func formatted(secondsPrecision precision: Int = 1) -> String {
        let shown = displayed(secondsPrecision: precision)
        return String(format: "%d° %d' %.\(precision)f\"", shown.degrees, shown.minutes, shown.seconds)
    }
}

extension DegreesDecimalMinutes: CustomStringConvertible {
    public var description: String {
        formatted(minutesPrecision: 3)
    }

    public func formatted(minutesPrecision precision: Int = 2) -> String {
        let shown = displayed(minutesPrecision: precision)
        return String(format: "%d° %.\(precision)f'", shown.degrees, shown.minutes)
    }
}

extension DegreesMinutesSeconds {
    public var asDegreesDecimalMinutes: DegreesDecimalMinutes {
        DegreesDecimalMinutes(decimalDegrees: asDecimalDegrees)
    }
}

extension DegreesDecimalMinutes {
    public var asDegreesMinutesSeconds: DegreesMinutesSeconds {
        DegreesMinutesSeconds(decimalDegrees: asDecimalDegrees)
    }
}

extension DegreesMinutesSeconds {
    public func formatted(direction: String, isLongitude: Bool = false, secondsPrecision precision: Int = 1) -> String {
        let degreeFormat = isLongitude ? "%03d" : "%02d"
        let totalWidth = precision + 3
        let shown = displayed(secondsPrecision: precision)
        return String(
            format: "\(degreeFormat)°%02d'%0\(totalWidth).\(precision)f\"\(direction)",
            shown.degrees, shown.minutes, shown.seconds
        )
    }
}

extension DegreesDecimalMinutes {
    public func formatted(direction: String, isLongitude: Bool = false, minutesPrecision precision: Int = 2) -> String {
        let degreeFormat = isLongitude ? "%03d" : "%02d"
        let totalWidth = precision + 3
        let shown = displayed(minutesPrecision: precision)
        return String(
            format: "\(degreeFormat)°%0\(totalWidth).\(precision)f'\(direction)",
            shown.degrees, shown.minutes
        )
    }
}
