import Foundation

public struct WindTriangle: Sendable {
    public static func groundspeed(
           tas: Measurement<UnitSpeed>,
           track: Measurement<UnitAngle>,
           wind: Wind
       ) -> CartesianVector<UnitSpeed> {
           // Convert aircraft track (bearing from north) to math polar
           // 0 rad = north, angles clockwise
           let trackRad = track.converted(to: .radians).value

           let tasVector = CartesianVector<UnitSpeed>(
               x: .init(value: tas.value * sin(trackRad), unit: tas.unit),
               y: .init(value: tas.value * cos(trackRad), unit: tas.unit)
           )

           // Wind vector already converted from meteorological bearing
           let windVector = wind.vector

           // Groundspeed = TAS vector + wind vector
           let gsVector = CartesianVector<UnitSpeed>(
               x: .init(value: tasVector.x.value + windVector.x.value, unit: tas.unit),
               y: .init(value: tasVector.y.value + windVector.y.value, unit: tas.unit)
           )

           return gsVector
       }
}
