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
        let deg = Int(unsigned)
        let minutesDecimal = (unsigned - Double(deg)) * 60.0
        let min = Int(minutesDecimal)
        let sec = (minutesDecimal - Double(min)) * 60.0
        
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
    
    public func formatted(secondsPrecision precision: Int = 2) -> String {
        String(format: "%d° %d' %.\(precision)f\"", degrees, minutes, seconds)
    }
}

extension DegreesDecimalMinutes: CustomStringConvertible {
    public var description: String {
        String(format: "%d° %.3f'", degrees, minutes)
    }
    
    public func formatted(minutesPrecision precision: Int = 3) -> String {
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
    public func formatted(direction: String, isLongitude: Bool = false) -> String {
        let degreeFormat = isLongitude ? "%03d" : "%02d"
        return String(
            format: "\(degreeFormat)°%02d'%05.2f\"\(direction)",
            degrees, minutes, seconds
        )
    }
}

extension DegreesDecimalMinutes {
    public func formatted(direction: String, isLongitude: Bool = false) -> String {
        let degreeFormat = isLongitude ? "%03d" : "%02d"
        return String(
            format: "\(degreeFormat)°%06.3f'\(direction)",
            degrees, minutes
        )
    }
}
