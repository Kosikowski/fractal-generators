# API Reference

This document provides a comprehensive reference for all public APIs in the FractalGenerators package.

## Table of Contents

1. [Core Protocols](#core-protocols)
2. [Parameter Structures](#parameter-structures)
3. [Generator Types](#generator-types)
4. [Factory Methods](#factory-methods)
5. [View Components](#view-components)
6. [Utility Types](#utility-types)
7. [Enums and Constants](#enums-and-constants)

## Core Protocols

### FractalGenerator

Base protocol for all fractal generators.

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

**Requirements:**
- `Parameters`: The parameter type for this generator
- `Output`: The output type (CGImage, Path, or [CGPoint])
- `generate(with:)`: Synchronous generation method
- `generateAsync(with:progress:completion:)`: Asynchronous generation with progress

### FractalParameters

Base protocol for fractal parameters.

```swift
protocol FractalParameters {
    var iterations: Int { get }
    var size: CGSize { get }
}
```

**Requirements:**
- `iterations`: Maximum number of iterations
- `size`: Output size in points

### ImageFractalGenerator

Protocol for generators that produce images.

```swift
protocol ImageFractalGenerator: FractalGenerator where Output == CGImage {
    func generateImage(with parameters: Parameters) -> CGImage
}
```

**Purpose**: For fractals that generate pixel-based images
**Examples**: Mandelbrot Set, Julia Set, Burning Ship, Plasma Fractal
**Why This Protocol Exists**:
- **Escape-time algorithms** need to compute color values for each pixel
- **Complex plane fractals** require direct pixel manipulation for optimal performance
- **Memory efficiency** - generates CGImage directly without intermediate arrays
- **GPU-friendly** - raw pixel data can be passed to Metal/OpenGL
- **High performance** - avoids creating intermediate color arrays

**Additional Requirements:**
- `generateImage(with:)`: Direct image generation method

### PathFractalGenerator

Protocol for generators that produce paths.

```swift
protocol PathFractalGenerator: FractalGenerator where Output == Path {
    func generatePath(with parameters: Parameters) -> Path
}
```

**Purpose**: For fractals that generate geometric paths
**Examples**: Sierpinski Triangle, Koch Snowflake, Dragon Curve, Hilbert Curve
**Why This Protocol Exists**:
- **Geometric fractals** are naturally defined as paths or curves
- **Vector-based rendering** provides infinite scalability
- **SwiftUI Path integration** enables smooth animations and transformations
- **Memory efficient** for recursive structures
- **Mathematical accuracy** - preserves exact geometric relationships

**Additional Requirements:**
- `generatePath(with:)`: Direct path generation method

### PointFractalGenerator

Protocol for generators that produce point clouds.

```swift
protocol PointFractalGenerator: FractalGenerator where Output == [CGPoint] {
    func generatePoints(with parameters: Parameters) -> [CGPoint]
}
```

**Purpose**: For fractals that generate point clouds
**Examples**: Lorenz Attractor, Rossler Attractor, Brownian Motion, Levy Flight
**Why This Protocol Exists**:
- **Dynamical systems** naturally produce sequences of points
- **Attractor fractals** are collections of trajectory points
- **Stochastic processes** generate point-based patterns
- **Efficient storage** - only stores meaningful points, not full images
- **Mathematical fidelity** - preserves the exact trajectory data

**Additional Requirements:**
- `generatePoints(with:)`: Direct point generation method

### ProgressiveFractalGenerator

Protocol for generators that support progressive rendering.

```swift
protocol ProgressiveFractalGenerator: FractalGenerator {
    func generateProgressive(with parameters: Parameters,
                           onProgress: @escaping (Output, Double) -> Void)
}
```

**Purpose**: For fractals that support progressive rendering
**Examples**: Mandelbrot Set, Julia Set (complex fractals that benefit from preview)
**Why This Protocol Exists**:
- **Complex computations** can take significant time
- **User experience** - shows low-res preview while computing high-res
- **Interactive exploration** - allows zooming and panning with immediate feedback
- **Resource management** - can cancel long computations
- **Responsive UI** - prevents blocking the main thread

**Additional Requirements:**
- `generateProgressive(with:onProgress:)`: Progressive rendering method

## Parameter Structures

Different fractal types use different parameter structures based on their mathematical requirements:

### ComplexPlaneParameters

Parameters for complex plane fractals (Mandelbrot, Julia, etc.).

```swift
struct ComplexPlaneParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let viewRect: ComplexRect
    let blockiness: Double
    let colorPalette: [Color]
}
```

**Properties:**
- `iterations`: Maximum iterations for escape-time algorithms
- `size`: Output image size
- `viewRect`: Complex plane region to render
- `blockiness`: Smoothing factor (0.0 = smooth, 1.0 = blocky)
- `colorPalette`: Array of colors for gradient

**Why This Structure**:
- `viewRect`: Defines the region of the complex plane to render
- `blockiness`: Controls smoothing vs. performance trade-off
- `colorPalette`: Enables artistic customization
- `iterations`: Critical for escape-time algorithms

### RecursiveFractalParameters

Parameters for recursive fractals (Sierpinski, Koch, etc.).

```swift
struct RecursiveFractalParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let depth: Int
    let colorPalette: [Color]
}
```

**Properties:**
- `iterations`: Maximum iterations
- `size`: Output size
- `depth`: Recursion depth
- `colorPalette`: Array of colors for gradient

**Why This Structure**:
- `depth`: Controls recursion level (more important than iterations)
- `size`: Determines the scale of the geometric structure
- `colorPalette`: For visual enhancement of the fractal

### AttractorParameters

Parameters for attractor fractals (Lorenz, Rossler, etc.).

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

**Properties:**
- `iterations`: Number of points to generate
- `size`: Output size
- `dt`: Time step for differential equations
- `initialConditions`: Starting conditions
- `scale`: Scaling factor for display
- `colorPalette`: Array of colors for gradient

**Why This Structure**:
- `dt`: Time step for differential equation integration
- `initialConditions`: Starting point for the dynamical system
- `scale`: Maps mathematical coordinates to screen coordinates
- `iterations`: Number of points to generate

## Generator Types

### Complex Plane Generators

#### MandelbrotGenerator

```swift
struct MandelbrotGenerator: ImageFractalGenerator, ProgressiveFractalGenerator
```

**Why ImageFractalGenerator**: Generates pixel colors based on escape time
**Why ProgressiveFractalGenerator**: Complex computation benefits from preview

**Methods:**
- `generate(with:)` → `CGImage`
- `generateImage(with:)` → `CGImage`
- `generateAsync(with:progress:completion:)`
- `generateProgressive(with:onProgress:)`

#### JuliaSetGenerator

```swift
struct JuliaSetGenerator: ImageFractalGenerator, ProgressiveFractalGenerator
```

**Why ImageFractalGenerator**: Generates pixel colors based on escape time
**Why ProgressiveFractalGenerator**: Complex computation benefits from preview

**Methods:**
- `generate(with:)` → `CGImage`
- `generateImage(with:)` → `CGImage`
- `generateAsync(with:progress:completion:)`
- `generateProgressive(with:onProgress:)`

#### BurningShipGenerator

```swift
struct BurningShipGenerator: ImageFractalGenerator
```

**Why ImageFractalGenerator**: Generates pixel colors based on escape time with absolute values

**Methods:**
- `generate(with:)` → `CGImage`
- `generateImage(with:)` → `CGImage`
- `generateAsync(with:progress:completion:)`

#### TricornFractalGenerator

```swift
struct TricornFractalGenerator: ImageFractalGenerator
```

**Why ImageFractalGenerator**: Generates pixel colors based on escape time with complex conjugate

**Methods:**
- `generate(with:)` → `CGImage`
- `generateImage(with:)` → `CGImage`
- `generateAsync(with:progress:completion:)`

### Geometric Generators

#### SierpinskiTriangleGenerator

```swift
struct SierpinskiTriangleGenerator: PathFractalGenerator
```

**Why PathFractalGenerator**: Naturally a geometric path structure

**Methods:**
- `generate(with:)` → `Path`
- `generatePath(with:)` → `Path`
- `generateAsync(with:progress:completion:)`

#### SierpinskiCarpetGenerator

```swift
struct SierpinskiCarpetGenerator: PathFractalGenerator
```

**Why PathFractalGenerator**: Naturally a geometric path structure

**Methods:**
- `generate(with:)` → `Path`
- `generatePath(with:)` → `Path`
- `generateAsync(with:progress:completion:)`

#### KochSnowflakeGenerator

```swift
struct KochSnowflakeGenerator: PathFractalGenerator
```

**Why PathFractalGenerator**: Naturally a geometric path structure

**Methods:**
- `generate(with:)` → `Path`
- `generatePath(with:)` → `Path`
- `generateAsync(with:progress:completion:)`

### Attractor Generators

#### LorenzAttractorGenerator

```swift
struct LorenzAttractorGenerator: PointFractalGenerator
```

**Why PointFractalGenerator**: Collection of trajectory points from dynamical system

**Methods:**
- `generate(with:)` → `[CGPoint]`
- `generatePoints(with:)` → `[CGPoint]`
- `generateAsync(with:progress:completion:)`

#### RosslerAttractorGenerator

```swift
struct RosslerAttractorGenerator: PointFractalGenerator
```

**Why PointFractalGenerator**: Collection of trajectory points from dynamical system

**Methods:**
- `generate(with:)` → `[CGPoint]`
- `generatePoints(with:)` → `[CGPoint]`
- `generateAsync(with:progress:completion:)`

#### HenonAttractorGenerator

```swift
struct HenonAttractorGenerator: PointFractalGenerator
```

**Why PointFractalGenerator**: Collection of trajectory points from discrete map

**Methods:**
- `generate(with:)` → `[CGPoint]`
- `generatePoints(with:)` → `[CGPoint]`
- `generateAsync(with:progress:completion:)`

### Stochastic Generators

#### BrownianMotionGenerator

```swift
struct BrownianMotionGenerator: PointFractalGenerator
```

**Why PointFractalGenerator**: Generates trajectory points from random walk

**Methods:**
- `generate(with:)` → `[CGPoint]`
- `generatePoints(with:)` → `[CGPoint]`
- `generateAsync(with:progress:completion:)`

#### FBMGenerator

```swift
struct FBMGenerator: PointFractalGenerator
```

**Why PointFractalGenerator**: Generates trajectory points from fractional Brownian motion

**Methods:**
- `generate(with:)` → `[CGPoint]`
- `generatePoints(with:)` → `[CGPoint]`
- `generateAsync(with:progress:completion:)`

#### PlasmaFractalGenerator

```swift
struct PlasmaFractalGenerator: ImageFractalGenerator
```

**Why ImageFractalGenerator**: Generates height map as pixel image

**Methods:**
- `generate(with:)` → `CGImage`
- `generateImage(with:)` → `CGImage`
- `generateAsync(with:progress:completion:)`

## Factory Methods

### FractalFactory

Static factory for creating fractal views.

#### Complex Plane Fractals

```swift
static func createMandelbrot(
    iterations: Int = 1000,
    viewRect: ComplexRect = ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5)),
    blockiness: Double = 0.5,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<MandelbrotGenerator>

static func createJuliaSet(
    iterations: Int = 1000,
    parameter: Complex = Complex(-0.7, 0.27),
    viewRect: ComplexRect = ComplexRect(Complex(-2.0, 1.5), Complex(2.0, -1.5)),
    blockiness: Double = 0.5,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<JuliaSetGenerator>

static func createBurningShip(
    iterations: Int = 1000,
    viewRect: ComplexRect = ComplexRect(Complex(-2.0, 1.5), Complex(2.0, -1.5)),
    blockiness: Double = 0.5,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<BurningShipGenerator>

static func createTricorn(
    iterations: Int = 1000,
    viewRect: ComplexRect = ComplexRect(Complex(-2.0, 1.5), Complex(2.0, -1.5)),
    blockiness: Double = 0.5,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<TricornFractalGenerator>
```

#### Geometric Fractals

```swift
static func createSierpinski(
    depth: Int = 6,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<SierpinskiTriangleGenerator>

static func createSierpinskiCarpet(
    depth: Int = 4,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<SierpinskiCarpetGenerator>

static func createKochSnowflake(
    depth: Int = 4,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<KochSnowflakeGenerator>

static func createCantorSet(
    depth: Int = 8,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<CantorSetGenerator>
```

#### Attractor Fractals

```swift
static func createLorenzAttractor(
    iterations: Int = 10000,
    dt: Double = 0.01,
    initialConditions: [Double] = [1.0, 1.0, 1.0],
    scale: Double = 50.0,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<LorenzAttractorGenerator>

static func createRosslerAttractor(
    iterations: Int = 8000,
    parameters: [Double] = [0.2, 0.2, 5.7],
    scale: Double = 50.0,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<RosslerAttractorGenerator>

static func createHenonAttractor(
    iterations: Int = 5000,
    parameters: [Double] = [1.4, 0.3],
    scale: Double = 50.0,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<HenonAttractorGenerator>
```

#### Stochastic Fractals

```swift
static func createBrownianMotion(
    iterations: Int = 10000,
    stepSize: Double = 1.0,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<BrownianMotionGenerator>

static func createFBM(
    iterations: Int = 10000,
    hurstParameter: Double = 0.7,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<FBMGenerator>

static func createPlasmaFractal(
    size: CGSize = CGSize(width: 512, height: 512),
    roughness: Double = 0.5
) -> GenericFractalView<PlasmaFractalGenerator>
```

## View Components

### GenericFractalView

Generic view that can display any type of fractal.

```swift
struct GenericFractalView<Generator: FractalGenerator>: View {
    let generator: Generator
    let parameters: Generator.Parameters
    @State private var image: CGImage?
    @State private var path: Path?
    @State private var points: [CGPoint] = []
    @State private var isLoading = true
    @State private var progress: Double = 0.0
    
    init(generator: Generator, parameters: Generator.Parameters)
    
    var body: some View
}
```

**Properties:**
- `generator`: The fractal generator
- `parameters`: The parameters for generation
- `image`: Generated image (for ImageFractalGenerator)
- `path`: Generated path (for PathFractalGenerator)
- `points`: Generated points (for PointFractalGenerator)
- `isLoading`: Loading state
- `progress`: Generation progress

**Why This Design**:
- **Type Safety**: Compile-time checking ensures correct parameter types
- **Polymorphism**: Same view can handle any generator type
- **Separation of Concerns**: Display logic separate from generation logic
- **Reusability**: Same view with different generators

## Utility Types

### ComplexRect

Represents a rectangle in the complex plane.

```swift
struct ComplexRect {
    let min: Complex
    let max: Complex
    
    init(_ min: Complex, _ max: Complex)
    init(center: Complex, size: Complex)
}
```

**Properties:**
- `min`: Minimum complex coordinate
- `max`: Maximum complex coordinate

### Complex

Complex number type from swift-numerics.

```swift
struct Complex<RealType> where RealType : FloatingPoint {
    let real: RealType
    let imaginary: RealType
    
    static let zero: Complex
    static let one: Complex
    static let i: Complex
    
    var magnitude: RealType { get }
    var phase: RealType { get }
}
```

**Common Operations:**
- `+`, `-`, `*`, `/`: Arithmetic operations
- `magnitude`: Absolute value
- `phase`: Argument (angle)

### HashablePoint

Hashable wrapper for CGPoint.

```swift
struct HashablePoint: Hashable {
    let x: Double
    let y: Double
    
    init(_ point: CGPoint)
    func toCGPoint() -> CGPoint
}
```

## Enums and Constants

### FractalTypeEnum

Enumeration of all available fractal types.

```swift
enum FractalTypeEnum: CaseIterable {
    case mandelbrot
    case juliaSet
    case burningShip
    case tricorn
    case sierpinski
    case sierpinskiCarpet
    case kochSnowflake
    case cantorSet
    case lorenzAttractor
    case rosslerAttractor
    case henonAttractor
    case brownianMotion
    case fbm
    case plasmaFractal
    // ... and many more
    
    var displayName: String { get }
    func createView() -> AnyView
}
```

**Methods:**
- `displayName`: Human-readable name
- `createView()`: Creates a view for this fractal type

### Color Palettes

Predefined color palettes for fractals.

```swift
extension Array where Element == Color {
    static let mandelbrotPalette: [Color]
    static let juliaPalette: [Color]
    static let rainbowPalette: [Color]
    static let firePalette: [Color]
    static let oceanPalette: [Color]
    static let sunsetPalette: [Color]
}
```

## Error Handling

### FractalGenerationError

Errors that can occur during fractal generation.

```swift
enum FractalGenerationError: Error {
    case invalidParameters(String)
    case generationFailed(String)
    case timeout
    case memoryError
}
```

## Performance Considerations

### Memory Management

- Generators use direct memory allocation for efficiency
- Images are created using `CGContext` for optimal performance
- Memory is automatically deallocated using `defer` blocks

### Async Operations

- All generators support async generation
- Progress callbacks are `@Sendable` for thread safety
- Background queues are used for computation

### Caching

- No built-in caching (implement at application level)
- Generators are stateless and can be reused
- Parameters are value types for efficient copying

## Platform Support

### Supported Platforms

- **macOS**: 12.0+
- **iOS**: 15.0+
- **Swift**: 5.10+

### Dependencies

- **swift-numerics**: Complex number support
- **SwiftUI**: UI framework
- **CoreGraphics**: Image generation

## Version Compatibility

### API Stability

- Public APIs follow semantic versioning
- Breaking changes only in major versions
- Deprecated APIs are marked with `@available` attributes

### Migration Guide

When upgrading between major versions:

1. Check the CHANGELOG.md for breaking changes
2. Update parameter types if needed
3. Review deprecated method usage
4. Test with your specific use cases

This API reference covers all public interfaces of the FractalGenerators package. For usage examples, see the [EXAMPLES.md](EXAMPLES.md) document. 