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

        // Round before carrying: floating-point noise can land seconds just
        // under 60 (e.g. 59.999999999987), which must still roll over into
        // minutes (and minutes into degrees) rather than display as "60.00s".
        sec = (sec * 100).rounded() / 100
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

extension DegreesMinutesSeconds: CustomStringConvertible {
    public var description: String {
        String(format: "%d° %d' %.2f\"", degrees, minutes, seconds)
    }

    public func formatted(secondsPrecision precision: Int = 1) -> String {
        String(format: "%d° %d' %.\(precision)f\"", degrees, minutes, seconds)
    }
}

extension DegreesDecimalMinutes: CustomStringConvertible {
    public var description: String {
        String(format: "%d° %.3f'", degrees, minutes)
    }

    public func formatted(minutesPrecision precision: Int = 2) -> String {
        String(format: "%d° %.\(precision)f'", degrees, minutes)
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
        return String(
            format: "\(degreeFormat)°%02d'%0\(totalWidth).\(precision)f\"\(direction)",
            degrees, minutes, seconds
        )
    }
}

extension DegreesDecimalMinutes {
    public func formatted(direction: String, isLongitude: Bool = false, minutesPrecision precision: Int = 2) -> String {
        let degreeFormat = isLongitude ? "%03d" : "%02d"
        let totalWidth = precision + 3
        return String(
            format: "\(degreeFormat)°%0\(totalWidth).\(precision)f'\(direction)",
            degrees, minutes
        )
    }
}
