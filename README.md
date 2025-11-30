# AviationMaths

A foundational aviation mathematics framework for iOS applications, providing production-ready implementations of industry-standard aviation calculations.

## Overview

AviationMaths is a Swift framework that delivers accurate, well-tested implementations of core aviation mathematical relationships. It serves as the foundation for specialized aviation applications, particularly those requiring precise atmospheric and airspeed calculations.

## Features

### Speed System
- **Calibrated Airspeed (CAS)** - Indicated airspeed corrected for instrument and position errors
- **Equivalent Airspeed (EAS)** - CAS corrected for compressibility effects
- **True Airspeed (TAS)** - Actual aircraft speed through the air mass
- **Mach Number** - Speed relative to the speed of sound

Complete conversion support between all speed types with validation against industry standards.

### Altitude System
- **True Altitude** calculations with pressure and temperature corrections
- **ISA Temperature Profiles** - International Standard Atmosphere temperature modeling
- **Standard Atmospheric Calculations** following ICAO standards
- Support for various altitude references and barometric settings

### Geometry
- **CartesianVector** - Two-dimensional vector operations
- **PolarVector** - Polar coordinate system support
- **Position2D** - Geodetic position calculations (planned)

## Coordinate System Convention

This library uses **aviation convention** throughout, where bearings are measured clockwise from North. This differs from standard mathematical convention (counter-clockwise from East) but aligns with how pilots, navigators, and aviation systems work in the real world.

**Key definitions:**
- **0° = North** (+y axis)
- **90° = East** (+x axis)
- **180° = South** (-y axis)
- **270° = West** (-x axis)
- **Angles increase clockwise**

**Trigonometric consequences:** The conversion between polar and Cartesian coordinates uses `x = magnitude × sin(bearing)` and `y = magnitude × cos(bearing)`, with the inverse `bearing = atan2(x, y)`. Note the swapped sine/cosine and reversed atan2 arguments compared to mathematical convention.

**Cartesian interpretation:** The x-component represents East-West displacement (positive = East), and the y-component represents North-South displacement (positive = North). When you see a `CartesianVector` with `x = 100, y = 0`, that's 100 units due East.

**Wind handling:** Wind is conventionally reported as the direction it blows *from* (e.g., "wind from 270" means wind coming from the West). The `Wind` struct stores this `fromDirection` but internally converts to a velocity vector pointing in the direction the wind pushes objects (the `toDirection`, which is the reciprocal bearing). This means `wind.vector` gives you a Cartesian vector you can directly add to an aircraft's velocity vector to compute groundspeed.

**Why this matters:** By enforcing aviation convention at the lowest level, all higher-level calculations (wind triangles, relative positions, track and drift) work correctly without scattered conversion code. A `PolarVector` with bearing 045° genuinely points Northeast, and adding two `CartesianVector`s produces geometrically correct results that match real-world navigation.


## Design Principles

- **SI Units Throughout** - Consistent use of International System of Units
- **ICAO Standards** - Follows International Civil Aviation Organization formulas
- **ISA Atmospheric Model** - Uses International Standard Atmosphere for reference conditions
- **Comprehensive Testing** - Over 70 test cases per system covering normal operations and edge cases
- **Industry Validation** - Calculations validated against established aviation references

## Requirements

- iOS 13.0+
- Swift 5.0+

## Architecture

AviationMaths provides foundational aviation mathematics separate from application-specific implementations. It is designed to be used as a dependency for specialized frameworks such as BallisticMaths, which adds ballistic-specific calculations and wind modeling.

## Testing

The framework includes extensive test suites validating:
- All conversion paths between speed types
- Atmospheric calculations across operational ranges
- Edge cases and boundary conditions
- Accuracy against industry-standard references

## Author

https://github.com/danleedham
