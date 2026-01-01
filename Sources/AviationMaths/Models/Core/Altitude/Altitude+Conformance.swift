extension Altitude {
    public static func == (lhs: Altitude, rhs: Altitude) -> Bool {
        // Compare in AMSL unless both have ground elevation (then use AGL)
        if lhs.context.groundElevation != nil && rhs.context.groundElevation != nil {
            return lhs.agl.meters == rhs.agl.meters
        } else {
            return lhs.amsl.meters == rhs.amsl.meters
        }
    }
}

extension Altitude: Hashable {
    public func hash(into hasher: inout Hasher) {
        if context.groundElevation != nil {
            hasher.combine(agl.meters)
        } else {
            hasher.combine(amsl.meters)
        }
    }
}

// MARK: - Comparable

extension Altitude: Comparable {
    public static func < (lhs: Altitude, rhs: Altitude) -> Bool {
        if lhs.context.groundElevation != nil && rhs.context.groundElevation != nil {
            return lhs.agl.meters < rhs.agl.meters
        } else {
            return lhs.amsl.meters < rhs.amsl.meters
        }
    }
}
