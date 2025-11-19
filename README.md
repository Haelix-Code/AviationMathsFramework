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
- **Vector2D** - Two-dimensional vector operations
- **PolarCoordinate** - Polar coordinate system support
- **Position2D** - Geodetic position calculations (planned)

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