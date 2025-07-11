# Generic Fractal Architecture

This document describes the generic fractal architecture implemented in the FractalGenerators package, which provides a modular, reusable, and parameterized system for fractal generation and display.

## Overview

The architecture separates fractal generation logic from display logic, enabling:
- **Reusability**: The same generator can be used with different parameters
- **Type Safety**: Compile-time checking of parameter types
- **Extensibility**: Easy addition of new fractal types
- **Performance**: Optimized image generation without intermediate arrays
- **Progressive Rendering**: Support for showing low-res previews while computing high-res

## Package Structure

```
FractalGenerators/
├── Sources/FractalGenerators/
│   ├── Core/
│   │   ├── FractalProtocols.swift      # Core protocols and parameters
│   │   ├── GenericFractalView.swift    # Generic display view
│   │   └── FractalFactory.swift        # Factory and registry
│   └── Generators/
│       ├── MandelbrotGenerator.swift   # Complex plane fractals
│       ├── JuliaSetGenerator.swift
│       ├── SierpinskiTriangleGenerator.swift
│       ├── LorenzAttractorGenerator.swift
│       └── [40+ other generators]      # Complete fractal library
├── Tests/FractalGeneratorsTests/
│   └── FractalGeneratorsTests.swift
├── DemoApp/
│   └── FractalsShowcase/              # Comprehensive demo app
└── docs/
    ├── ARCHITECTURE.md                 # This documentation
    ├── FRACTAL_TYPES.md               # Fractal type descriptions
    └── [Other documentation]
```

## Architecture Components

### 1. Core Protocols

#### `FractalGenerator`
Base protocol for all fractal generators:
```swift
protocol FractalGenerator {
    associatedtype Parameters: FractalParameters
    associatedtype Output
    
    func generate(with parameters: Parameters) -> Output
    func generateAsync(with parameters: Parameters, 
                      progress: @escaping @Sendable (Double) -> Void,
                      completion: @escaping @Sendable (Output) -> Void)
}
```

#### Specialized Generator Protocols

The architecture defines four specialized protocols based on the **mathematical nature** and **output requirements** of different fractal types:

##### ImageFractalGenerator
**Purpose**: For fractals that generate pixel-based images
**Examples**: Mandelbrot Set, Julia Set, Burning Ship, Plasma Fractal
**Why This Type Exists**:
- **Escape-time algorithms** need to compute color values for each pixel
- **Complex plane fractals** require direct pixel manipulation for optimal performance
- **Memory efficiency** - generates CGImage directly without intermediate arrays
- **GPU-friendly** - raw pixel data can be passed to Metal/OpenGL

```swift
protocol ImageFractalGenerator: FractalGenerator where Output == CGImage {
    func generateImage(with parameters: Parameters) -> CGImage
}
```

##### PathFractalGenerator
**Purpose**: For fractals that generate geometric paths
**Examples**: Sierpinski Triangle, Koch Snowflake, Dragon Curve, Hilbert Curve
**Why This Type Exists**:
- **Geometric fractals** are naturally defined as paths or curves
- **Vector-based rendering** provides infinite scalability
- **SwiftUI Path integration** enables smooth animations and transformations
- **Memory efficient** for recursive structures

```swift
protocol PathFractalGenerator: FractalGenerator where Output == Path {
    func generatePath(with parameters: Parameters) -> Path
}
```

##### PointFractalGenerator
**Purpose**: For fractals that generate point clouds
**Examples**: Lorenz Attractor, Rossler Attractor, Brownian Motion, Levy Flight
**Why This Type Exists**:
- **Dynamical systems** naturally produce sequences of points
- **Attractor fractals** are collections of trajectory points
- **Stochastic processes** generate point-based patterns
- **Efficient storage** - only stores meaningful points, not full images

```swift
protocol PointFractalGenerator: FractalGenerator where Output == [CGPoint] {
    func generatePoints(with parameters: Parameters) -> [CGPoint]
}
```

##### ProgressiveFractalGenerator
**Purpose**: For fractals that support progressive rendering
**Examples**: Mandelbrot Set, Julia Set (complex fractals that benefit from preview)
**Why This Type Exists**:
- **Complex computations** can take significant time
- **User experience** - shows low-res preview while computing high-res
- **Interactive exploration** - allows zooming and panning with immediate feedback
- **Resource management** - can cancel long computations

```swift
protocol ProgressiveFractalGenerator: FractalGenerator {
    func generateProgressive(with parameters: Parameters,
                           onProgress: @escaping (Output, Double) -> Void)
}
```

### 2. Parameter Structures

Different fractal types use different parameter structures based on their mathematical requirements:

#### `ComplexPlaneParameters`
For complex plane fractals (Mandelbrot, Julia):
```swift
struct ComplexPlaneParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let viewRect: ComplexRect
    let blockiness: Double
    let colorPalette: [Color]
}
```

**Why This Structure**:
- `viewRect`: Defines the region of the complex plane to render
- `blockiness`: Controls smoothing vs. performance trade-off
- `colorPalette`: Enables artistic customization
- `iterations`: Critical for escape-time algorithms

#### `RecursiveFractalParameters`
For recursive fractals (Sierpinski, Koch):
```swift
struct RecursiveFractalParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let depth: Int
    let colorPalette: [Color]
}
```

**Why This Structure**:
- `depth`: Controls recursion level (more important than iterations)
- `size`: Determines the scale of the geometric structure
- `colorPalette`: For visual enhancement of the fractal

#### `AttractorParameters`
For attractor fractals (Lorenz, Rossler):
```swift
struct AttractorParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let dt: Double
    let initialConditions: [Double]
    let scale: Double
    let colorPalette: [Color]
}
```

**Why This Structure**:
- `dt`: Time step for differential equation integration
- `initialConditions`: Starting point for the dynamical system
- `scale`: Maps mathematical coordinates to screen coordinates
- `iterations`: Number of points to generate

### 3. Generic View

The `GenericFractalView` can display any type of fractal:
```swift
struct GenericFractalView<Generator: FractalGenerator>: View {
    let generator: Generator
    let parameters: Generator.Parameters
    
    // Automatically handles different generator types
    // and displays appropriate content (image, path, or points)
}
```

**Why This Design**:
- **Type Safety**: Compile-time checking ensures correct parameter types
- **Polymorphism**: Same view can handle any generator type
- **Separation of Concerns**: Display logic separate from generation logic
- **Reusability**: Same view with different generators

## Implementation Examples

### Mandelbrot Generator (Image + Progressive)
```swift
struct MandelbrotGenerator: ImageFractalGenerator, ProgressiveFractalGenerator {
    func generate(with parameters: ComplexPlaneParameters) -> CGImage {
        return generateImage(with: parameters)
    }
    
    func generateImage(with parameters: ComplexPlaneParameters) -> CGImage {
        // Direct image generation for optimal performance
        // Returns CGImage instead of [[Color]] for memory efficiency
    }
    
    func generateProgressive(with parameters: ComplexPlaneParameters,
                           onProgress: @escaping (CGImage, Double) -> Void) {
        // Progressive rendering from low to high resolution
    }
}
```

**Why ImageFractalGenerator**: Mandelbrot generates pixel colors based on escape time
**Why ProgressiveFractalGenerator**: Complex computation benefits from preview

### Sierpinski Triangle Generator (Path)
```swift
struct SierpinskiTriangleGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }
    
    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        // Recursive path generation
    }
}
```

**Why PathFractalGenerator**: Sierpinski is naturally a geometric path structure

### Lorenz Attractor Generator (Point)
```swift
struct LorenzAttractorGenerator: PointFractalGenerator {
    func generate(with parameters: AttractorParameters) -> [CGPoint] {
        return generatePoints(with: parameters)
    }
    
    func generatePoints(with parameters: AttractorParameters) -> [CGPoint] {
        // Point cloud generation for attractors
    }
}
```

**Why PointFractalGenerator**: Lorenz attractor is a collection of trajectory points

## Factory Pattern

The `FractalFactory` provides convenient creation methods:

```swift
struct FractalFactory {
    static func createMandelbrot(
        iterations: Int = 1000,
        viewRect: ComplexRect = ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5)),
        blockiness: Double = 0.5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<MandelbrotGenerator> {
        let generator = MandelbrotGenerator()
        let parameters = ComplexPlaneParameters(
            iterations: iterations,
            size: size,
            viewRect: viewRect,
            blockiness: blockiness
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }
}
```

**Why Factory Pattern**:
- **Convenience**: Hides complexity of generator/parameter creation
- **Consistency**: Ensures proper parameter combinations
- **Discoverability**: Easy to find available fractal types
- **Type Safety**: Compile-time parameter validation

## Available Generators

The package includes over 40 different fractal generators:

### Complex Plane Fractals (ImageFractalGenerator)
- `MandelbrotGenerator` - Classic Mandelbrot Set
- `JuliaSetGenerator` - Julia Sets with parameter c
- `BurningShipGenerator` - Burning Ship variant
- `TricornFractalGenerator` - Tricorn (Mandelbar) Set
- `BuddhabrotGenerator` - Buddhabrot visualization
- `NewtonFractalGenerator` - Newton's method fractals

**Why ImageFractalGenerator**: These generate pixel-based images from escape-time algorithms

### Geometric Fractals (PathFractalGenerator)
- `SierpinskiTriangleGenerator` - Sierpinski Triangle
- `SierpinskiCarpetGenerator` - Sierpinski Carpet
- `SierpinskiArrowheadGenerator` - Sierpinski Arrowhead
- `KochSnowflakeGenerator` - Koch Snowflake
- `CantorSetGenerator` - Cantor Set
- `CantorDustGenerator` - Cantor Dust
- `MengerCubeGenerator` - Menger Cube
- `MangerSpongeGenerator` - Menger Sponge

**Why PathFractalGenerator**: These are naturally defined as geometric paths

### Space-Filling Curves (PathFractalGenerator)
- `DragonCurveGenerator` - Dragon Curve
- `HeighwayDragonGenerator` - Heighway Dragon
- `HilbertCurveGenerator` - Hilbert Curve
- `PeanoCurveGenerator` - Peano Curve
- `GosperCurveGenerator` - Gosper Curve
- `LevyCCurveGenerator` - Levy C Curve

**Why PathFractalGenerator**: These are continuous curves that fill space

### Strange Attractors (PointFractalGenerator)
- `LorenzAttractorGenerator` - Lorenz Attractor
- `RosslerAttractorGenerator` - Rössler Attractor
- `HenonAttractorGenerator` - Henon Attractor
- `CliffordAttractorGenerator` - Clifford Attractor
- `ChuaCircuitGenerator` - Chua's Circuit
- `DeJongAttractorGenerator` - DeJong Attractor

**Why PointFractalGenerator**: These generate point clouds from dynamical systems

### Random/Stochastic Fractals
- `BrownianMotionGenerator` - Brownian Motion (PointFractalGenerator)
- `FBMGenerator` - Fractional Brownian Motion (PointFractalGenerator)
- `LevyFlightGenerator` - Levy Flight (PointFractalGenerator)
- `PlasmaFractalGenerator` - Plasma Fractal (ImageFractalGenerator)
- `DiamondSquareGenerator` - Diamond-Square Algorithm (ImageFractalGenerator)
- `PerliniNoiseGenerator` - Perlin Noise (ImageFractalGenerator)
- `SimplexNoiseGenerator` - Simplex Noise (ImageFractalGenerator)

**Why Mixed Types**: Some generate points (trajectories), others generate images (height maps)

### Natural Patterns
- `TreeBranchingGenerator` - Tree Branching (PathFractalGenerator)
- `RiverNetworkGenerator` - River Networks (PathFractalGenerator)
- `LightningPatternGenerator` - Lightning Patterns (PathFractalGenerator)
- `SnowFlakeGenerator` - Snowflakes (PathFractalGenerator)
- `RomanescoBroccoliGenerator` - Romanesco Broccoli (PathFractalGenerator)
- `CoastlineGenerator` - Coastlines (PathFractalGenerator)

**Why PathFractalGenerator**: These model natural structures as geometric paths

### IFS and Other
- `ApollonianGasketGenerator` - Apollonian Gasket (ImageFractalGenerator)
- `PythagoreanTreeGenerator` - Pythagorean Tree (PathFractalGenerator)
- `FractalFlamesGenerator` - Fractal Flames (ImageFractalGenerator)
- `IFSGenerator` - Generic IFS (ImageFractalGenerator)
- `BoxCountingGenerator` - Box Counting (PointFractalGenerator)
- `LangtonsAntGenerator` - Langton's Ant (ImageFractalGenerator)
- `ConwaysGameOfLifeGenerator` - Conway's Game of Life (ImageFractalGenerator)

**Why Mixed Types**: Depends on whether they generate images, paths, or points

## Usage Examples

### Basic Usage
```swift
struct ContentView: View {
    var body: some View {
        FractalFactory.createMandelbrot(iterations: 2000)
            .frame(width: 400, height: 400)
    }
}
```

### Parameterized Usage
```swift
struct FractalGalleryView: View {
    @State private var iterations: Double = 1000
    @State private var depth: Double = 6
    
    var body: some View {
        VStack {
            FractalFactory.createMandelbrot(iterations: Int(iterations))
                .frame(width: 300, height: 300)
            
            FractalFactory.createSierpinski(depth: Int(depth))
                .frame(width: 300, height: 300)
            
            Slider(value: $iterations, in: 100...5000)
            Slider(value: $depth, in: 1...10)
        }
    }
}
```

### Custom Generator Usage
```swift
struct CustomFractalView: View {
    let generator = LorenzAttractorGenerator()
    let parameters = AttractorParameters(
        iterations: 10000,
        size: CGSize(width: 600, height: 600),
        dt: 0.01,
        initialConditions: [1.0, 1.0, 1.0],
        scale: 50.0
    )
    
    var body: some View {
        GenericFractalView(generator: generator, parameters: parameters)
    }
}
```

## Benefits of the Architecture

### 1. Performance Improvements
- **Direct Image Generation**: Returns `CGImage` instead of `[[Color]]`
- **Memory Efficiency**: No intermediate color arrays
- **GPU-Friendly**: Raw pixel data can be easily passed to Metal/OpenGL
- **Progressive Rendering**: Shows low-res preview while computing high-res

### 2. Code Organization
- **Separation of Concerns**: Generation logic separated from display logic
- **Reusability**: Same generator with different parameters
- **Type Safety**: Compile-time parameter validation
- **Testability**: Each component can be tested independently

### 3. Extensibility
- **Easy Addition**: New fractals just need to implement the appropriate protocol
- **Parameter Flexibility**: Each fractal type can have its own parameter structure
- **Display Flexibility**: Same generator can be used in different contexts

### 4. User Experience
- **Loading States**: Built-in progress indicators
- **Progressive Rendering**: Immediate feedback with improving quality
- **Parameter Controls**: Real-time parameter adjustment
- **Caching**: Generated images can be cached and reused

## Migration Strategy

To migrate existing fractal implementations:

1. **Create Generator**: Implement the appropriate protocol
2. **Define Parameters**: Create or use existing parameter structure
3. **Update Views**: Replace direct implementation with `GenericFractalView`
4. **Add to Factory**: Add convenience method to `FractalFactory`

### Example Migration
```swift
// Before
struct MandelbrotView: View {
    var body: some View {
        Canvas { context, size in
            // Direct implementation
        }
    }
}

// After
struct MandelbrotView: View {
    var body: some View {
        FractalFactory.createMandelbrot()
    }
}
```

## Future Enhancements

1. **GPU Acceleration**: Metal compute shaders for complex fractals
2. **Caching System**: Intelligent caching of generated fractals
3. **Animation Support**: Smooth transitions between parameter changes
4. **Export Features**: Save fractals as images or videos
5. **Plugin System**: Dynamic loading of new fractal types
6. **3D Support**: Extend to 3D fractals and visualization
7. **Real-time Collaboration**: Multi-user fractal exploration

## File Structure

```
FractalGenerators/
├── Sources/FractalGenerators/
│   ├── Core/
│   │   ├── FractalProtocols.swift      # Core protocols and parameters
│   │   ├── GenericFractalView.swift    # Generic display view
│   │   └── FractalFactory.swift        # Factory and registry
│   └── Generators/
│       ├── [40+ generator files]       # Complete fractal library
├── Tests/FractalGeneratorsTests/
│   └── FractalGeneratorsTests.swift
├── DemoApp/
│   └── FractalsShowcase/              # Comprehensive demo app
└── docs/
    ├── ARCHITECTURE.md                 # This documentation
    ├── FRACTAL_TYPES.md               # Fractal type descriptions
    └── [Other documentation]
```

This architecture provides a solid foundation for a scalable, maintainable, and performant fractal generation system that can be easily extended with new fractal types and features. 