extension Altitude {
    public static func == (lhs: Altitude, rhs: Altitude) -> Bool {
        // AMSL is always the comparison basis, so == and hash(into:) can never
        // disagree about which quantity they're comparing/hashing.
        lhs.amsl.meters == rhs.amsl.meters
    }
}

extension Altitude: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(amsl.meters)
    }
}

// MARK: - Comparable

extension Altitude: Comparable {
    public static func < (lhs: Altitude, rhs: Altitude) -> Bool {
        lhs.amsl.meters < rhs.amsl.meters
    }
}
