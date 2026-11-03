import Foundation

/// Unit of force for aviation applications.
///
/// Foundation's Measurement framework doesn't include UnitForce, so we provide our own.
/// Common units include Newtons (SI), decanewtons (common in European aviation for
/// weight and balance), and pounds-force (common in US aviation).
///
/// Example usage:
/// ```swift
/// let thrust = Measurement<UnitForce>(value: 100, unit: .kilonewtons)
/// let thrustInLbf = thrust.converted(to: .poundsForce)  // ~22,480 lbf
/// ```
public final class UnitForce: Dimension, @unchecked Sendable {

    // MARK: - SI Units

    /// Newtons (N) - SI base unit of force
    /// 1 N = 1 kg⋅m/s²
    public static let newtons = UnitForce(
        symbol: "N",
        converter: UnitConverterLinear(coefficient: 1.0)
    )

    /// Kilonewtons (kN)
    /// 1 kN = 1000 N
    public static let kilonewtons = UnitForce(
        symbol: "kN",
        converter: UnitConverterLinear(coefficient: 1000.0)
    )

    /// Decanewtons (daN) - commonly used in European aviation for weight and balance
    /// 1 daN = 10 N
    public static let decanewtons = UnitForce(
        symbol: "daN",
        converter: UnitConverterLinear(coefficient: 10.0)
    )

    // MARK: - Imperial/US Units

    /// Pounds-force (lbf) - commonly used in US aviation
    /// 1 lbf = 4.4482216152605 N (exact by definition)
    public static let poundsForce = UnitForce(
        symbol: "lbf",
        converter: UnitConverterLinear(coefficient: 4.4482216152605)
    )

    // MARK: - Metric Gravitational Units

    /// Kilogram-force (kgf) - legacy metric unit, equals weight of 1 kg at standard gravity
    /// 1 kgf = g₀ × 1 kg = 9.80665 N (exact by definition)
    public static let kilogramForce = UnitForce(
        symbol: "kgf",
        converter: UnitConverterLinear(coefficient: 9.80665)
    )

    // MARK: - Base Unit

    public override static func baseUnit() -> UnitForce {
        return .newtons
    }
}

// MARK: - Convenience Initializers

public extension Measurement where UnitType == UnitForce {

    /// Initialize with value in Newtons
    init(newtons: Double) {
        self.init(value: newtons, unit: .newtons)
    }

    /// Initialize with value in decanewtons
    init(decanewtons: Double) {
        self.init(value: decanewtons, unit: .decanewtons)
    }

    /// Initialize with value in kilonewtons
    init(kilonewtons: Double) {
        self.init(value: kilonewtons, unit: .kilonewtons)
    }

    /// Initialize with value in pounds-force
    init(poundsForce: Double) {
        self.init(value: poundsForce, unit: .poundsForce)
    }

    /// Initialize with value in kilogram-force
    init(kilogramForce: Double) {
        self.init(value: kilogramForce, unit: .kilogramForce)
    }
}

// MARK: - Convenience Accessors

public extension Measurement where UnitType == UnitForce {

    /// Value in Newtons
    var newtons: Double {
        converted(to: .newtons).value
    }

    /// Value in decanewtons
    var decanewtons: Double {
        converted(to: .decanewtons).value
    }

    /// Value in kilonewtons
    var kilonewtons: Double {
        converted(to: .kilonewtons).value
    }

    /// Value in pounds-force
    var poundsForce: Double {
        converted(to: .poundsForce).value
    }

    /// Value in kilogram-force
    var kilogramForce: Double {
        converted(to: .kilogramForce).value
    }
}
