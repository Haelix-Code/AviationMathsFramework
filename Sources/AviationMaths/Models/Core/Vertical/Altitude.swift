import Foundation

public final class UnitAltitude: Dimension {

    public static let agl = UnitAltitude(
        symbol: "AGL",
        converter: UnitConverterLinear(coefficient: 1.0)
    )
    
    public static func amsl(context: AltitudeContext) -> UnitAltitude {
        UnitAltitude(
            symbol: "AMSL",
            converter: AGLtoAMSLConverter(context: context)
        )
    }
    
    public static func pressureAltitude(context: AltitudeContext) -> UnitAltitude {
        UnitAltitude(
            symbol: "PA",
            converter: AGLtoPressureAltitudeConverter(context: context)
        )
    }
    
    public static func trueAltitude(context: AltitudeContext) -> UnitAltitude {
        UnitAltitude(
            symbol: "True Altitude",
            converter: AGLtoTrueAltitudeConverter(context: context)
        )
    }
    
    public static func flightLevel(context: AltitudeContext) -> UnitAltitude {
        UnitAltitude(
            symbol: "FL",
            converter: AGLtoPressureAltitudeConverter(context: context)
        )
    }
    
    override public class func baseUnit() -> Self {
        // swiftlint:disable:next force_cast
        return agl as! Self
    }
}

// MARK: - Unit Converters

/// Converter from AGL to AMSL (simple offset)
private final class AGLtoAMSLConverter: UnitConverter {
    private let groundElevationMeters: Double
    
    init(context: AltitudeContext) {
        guard let groundElev = context.groundElevation else {
            fatalError("Ground elevation required for AGL to AMSL conversion")
        }
        self.groundElevationMeters = groundElev.converted(to: .meters).value
    }
    
    /// Convert from AGL (base unit) to AMSL
    /// AMSL = AGL + groundElevation
    override func value(fromBaseUnitValue baseValue: Double) -> Double {
        baseValue + groundElevationMeters
    }
    
    /// Convert from AMSL to AGL (base unit)
    /// AGL = AMSL - groundElevation
    override func baseUnitValue(fromValue value: Double) -> Double {
        value - groundElevationMeters
    }
}

/// Converter from AGL to Pressure Altitude
private final class AGLtoPressureAltitudeConverter: UnitConverter {
    private let groundElevationMeters: Double
    private let qnhPascals: Double
    
    init(context: AltitudeContext) {
        guard let groundElev = context.groundElevation,
              let qnh = context.qnh else {
            fatalError("Ground elevation and QNH required for pressure altitude conversion")
        }
        self.groundElevationMeters = groundElev.converted(to: .meters).value
        self.qnhPascals = qnh.converted(to: .newtonsPerMetersSquared).value
    }
    
    /// Convert from AGL (base unit) to Pressure Altitude
    ///
    /// Steps:
    /// 1. AGL + groundElevation = AMSL (meters)
    /// 2. AMSL → pressure using QNH as reference
    /// 3. pressure → PA using standard pressure (1013.25 hPa) as reference
    override func value(fromBaseUnitValue baseValue: Double) -> Double {
        // Step 1: AGL to AMSL
        let amslMeters = baseValue + groundElevationMeters
        
        // Step 2: AMSL to pressure at that altitude (using QNH)
        let pressureAtAMSL = BarometricEquations.pressureFromAltitude(
            altitude: amslMeters,
            referencePressure: qnhPascals
        )
        
        // Step 3: Convert that pressure to altitude using standard pressure
        return BarometricEquations.altitudeFromPressure(
            pressure: pressureAtAMSL,
            referencePressure: ISA.seaLevelPressure.pascals
        )
    }
    
    /// Convert from Pressure Altitude to AGL (base unit)
    ///
    /// Steps:
    /// 1. PA → pressure using standard pressure as reference
    /// 2. pressure → AMSL using QNH as reference
    /// 3. AMSL - groundElevation = AGL (meters)
    override func baseUnitValue(fromValue value: Double) -> Double {
        // Step 1: PA to pressure
        let pressureAtPA = BarometricEquations.pressureFromAltitude(
            altitude: value,
            referencePressure: ISA.seaLevelPressure.pascals
        )
        
        // Step 2: Pressure to AMSL altitude (using QNH)
        let amslMeters = BarometricEquations.altitudeFromPressure(
            pressure: pressureAtPA,
            referencePressure: qnhPascals
        )
        
        // Step 3: AMSL to AGL
        return amslMeters - groundElevationMeters
    }
}

/// Converter from AGL to True Altitude (with temperature correction)
private final class AGLtoTrueAltitudeConverter: UnitConverter {
    private let groundElevationMeters: Double
    private let qnhPascals: Double
    private let surfaceTemperatureK: Double
    private let lapseRate: Double
    
    init(context: AltitudeContext) {
        guard let groundElev = context.groundElevation,
              let qnh = context.qnh,
              let surfaceTemp = context.surfaceTemperature else {
            fatalError("Ground elevation, QNH, and surface temperature required for true altitude conversion")
        }
        
        self.groundElevationMeters = groundElev.converted(to: .meters).value
        self.qnhPascals = qnh.converted(to: .newtonsPerMetersSquared).value
        self.surfaceTemperatureK = surfaceTemp.converted(to: .kelvin).value
        self.lapseRate = context.lapseRate
    }
    
    /// Convert from AGL (base unit) to True Altitude
    ///
    /// Steps:
    /// 1. AGL + groundElevation = AMSL (dropAltitudeAMSL)
    /// 2. Calculate sea level temperature from surface temp
    /// 3. AMSL → pressure using QNH
    /// 4. pressure → true altitude using actual temperature profile
    override func value(fromBaseUnitValue baseValue: Double) -> Double {
        // Step 1: AGL to AMSL
        let dropAltitudeAMSL = baseValue + groundElevationMeters
        
        // Step 2: Calculate sea level temperature
        // T_seaLevel = T_surface - (lapseRate × groundElevation)
        let seaLevelTemperatureK = surfaceTemperatureK - (lapseRate * groundElevationMeters)
        
        // Step 3: AMSL to pressure at that altitude
        let pressureAtDropAltitude = BarometricEquations.pressureFromAltitude(
            altitude: dropAltitudeAMSL,
            referencePressure: qnhPascals,
            temperature: seaLevelTemperatureK,
            lapseRate: lapseRate
        )
        
        // Step 4: Pressure to true altitude using actual temperature profile
        return BarometricEquations.altitudeFromPressure(
            pressure: pressureAtDropAltitude,
            referencePressure: qnhPascals,
            temperature: seaLevelTemperatureK,
            lapseRate: lapseRate
        )
    }
    
    /// Convert from True Altitude to AGL (base unit)
    ///
    /// This is the reverse: given true altitude, find AGL
    override func baseUnitValue(fromValue value: Double) -> Double {
        // Calculate sea level temperature
        let seaLevelTemperatureK = surfaceTemperatureK - (lapseRate * groundElevationMeters)
        
        // True altitude to pressure
        let pressureAtTrueAltitude = BarometricEquations.pressureFromAltitude(
            altitude: value,
            referencePressure: qnhPascals,
            temperature: seaLevelTemperatureK,
            lapseRate: lapseRate
        )
        
        // Pressure to AMSL
        let dropAltitudeAMSL = BarometricEquations.altitudeFromPressure(
            pressure: pressureAtTrueAltitude,
            referencePressure: qnhPascals,
            temperature: seaLevelTemperatureK,
            lapseRate: lapseRate
        )
        
        // AMSL to AGL
        return dropAltitudeAMSL - groundElevationMeters
    }
}
