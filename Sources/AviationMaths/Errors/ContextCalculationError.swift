import Foundation

public enum ContextCalculationError: Error, Equatable, Sendable, LocalizedError {
    case insufficientData(calculation: String, missing: [String])

    public var errorDescription: String? {
        switch self {
        case .insufficientData(let calculation, let missing):
            return "Cannot calculate \(calculation): missing \(missing.joined(separator: ", "))"
        }
    }
}
