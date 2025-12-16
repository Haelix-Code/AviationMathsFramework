extension VerticalReference {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        if let match = VerticalReference.allCases.first(where: {
            $0.abbreviation.caseInsensitiveCompare(value) == .orderedSame ||
            $0.rawValue.caseInsensitiveCompare(value) == .orderedSame
        }) {
            self = match
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown VerticalReference value: \(value)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.abbreviation)
    }
}
