public enum ContextCalculationError: Error, Equatable {
    case insufficientData(calculation: String, missing: [String])
    
    public var localizedDescription: String {
        switch self {
        case .insufficientData(let calculation, let missing):
            return "Cannot calculate \(calculation): missing \(missing.joined(separator: ", "))"
        }
    }
}
