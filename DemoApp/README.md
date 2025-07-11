# FractalGenerators Demo App

This directory contains a comprehensive demo application showcasing all the fractal types available in the FractalGenerators package.

## Overview

The demo app demonstrates:
- All 40+ fractal types supported by the package
- Interactive parameter controls
- Real-time fractal generation
- Progressive rendering capabilities
- Different architectural approaches

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- macOS 12.0 or later
- The FractalGenerators package (included as local dependency)

### Running the Demo

1. Open the project in Xcode:
   ```bash
   open DemoApp/FractalsShowcase.xcodeproj
   ```

2. Select the "FractalsShowcase" scheme

3. Build and run the app

### Demo Features

- **Fractal Gallery**: Browse all available fractal types
- **Interactive Controls**: Adjust parameters in real-time
- **Architecture Comparison**: See different implementation approaches
- **Performance Testing**: Compare generation speeds
- **Export Capabilities**: Save fractals as images

## Project Structure

```
DemoApp/
├── FractalsShowcase/
│   ├── Fractals/              # Individual fractal view implementations
│   ├── ContentView.swift      # Main app interface
│   ├── MainContentView.swift  # Navigation and layout
│   ├── NewGeneratorContentView.swift  # New architecture demo
│   ├── GenericFractalDemoView.swift  # Generic view demo
│   └── SimpleArchitectureDemo.swift  # Simple implementation demo
├── FractalsShowcaseTests/     # Unit tests
└── FractalsShowcaseUITests/   # UI tests
```

## Demo Sections

### 1. Fractal Gallery
Browse and interact with all fractal types:
- Complex plane fractals (Mandelbrot, Julia, etc.)
- Geometric fractals (Sierpinski, Koch, etc.)
- Strange attractors (Lorenz, Rossler, etc.)
- Stochastic fractals (Brownian motion, plasma, etc.)

### 2. Architecture Demo
Compare different implementation approaches:
- **Legacy Views**: Individual SwiftUI views for each fractal
- **Generic Architecture**: Using the new generic fractal system
- **Factory Pattern**: Using FractalFactory convenience methods

### 3. Interactive Examples
- Real-time parameter adjustment
- Progressive rendering demonstrations
- Performance comparisons
- Export functionality

## Building from Command Line

```bash
# Build the demo app
xcodebuild -project DemoApp/FractalsShowcase.xcodeproj -scheme FractalsShowcase build

# Run tests
xcodebuild -project DemoApp/FractalsShowcase.xcodeproj -scheme FractalsShowcase test
```

## Troubleshooting

### Common Issues

1. **Build Errors**: Ensure the FractalGenerators package is properly linked
2. **Missing Dependencies**: Check that swift-numerics is resolved
3. **Performance Issues**: Reduce iteration counts for faster generation

### Getting Help

- Check the main package documentation in `../docs/`
- Review the architecture guide for implementation details
- See examples in the EXAMPLES.md file

## Contributing

When adding new features to the demo app:

1. Follow the existing code style
2. Add appropriate tests
3. Update this README if needed
4. Ensure compatibility with the main package

The demo app serves as both a showcase and a testing ground for the FractalGenerators package features. 