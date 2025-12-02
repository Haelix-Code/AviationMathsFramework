import Foundation

public protocol SpeedType {}
public enum CASType: SpeedType {}
public enum EASType: SpeedType {}
public enum TASType: SpeedType {}
public enum MachType: SpeedType {}

public struct TypedSpeed<Reference: SpeedType>: Sendable {
    public let value: Measurement<UnitSpeed>

    public init(_ value: Measurement<UnitSpeed>) {
        self.value = value
    }

    public init(knots: Double) {
        self.value = .init(knots: knots)
    }

    public init(mps: Double) {
        self.value = .init(mps: mps)
    }
}

public typealias CAS = TypedSpeed<CASType>
public typealias EAS = TypedSpeed<EASType>
public typealias TAS = TypedSpeed<TASType>

extension TypedSpeed where Reference == CASType {
    public func toEAS(context: SpeedContext) -> EAS {
        let speed = Speed(value: value, reference: .calibratedAirspeed, context: context)
        return EAS(speed.eas)
    }

    public func toTAS(context: SpeedContext) -> TAS {
        let speed = Speed(value: value, reference: .calibratedAirspeed, context: context)
        return TAS(speed.tas)
    }
}

extension TypedSpeed where Reference == TASType {
    public func toCAS(context: SpeedContext) -> CAS {
        let speed = Speed(value: value, reference: .trueAirspeed, context: context)
        return CAS(speed.cas)
    }
}
