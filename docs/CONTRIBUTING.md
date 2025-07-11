# Contributing to FractalGenerators

Thank you for your interest in contributing to FractalGenerators! This document provides guidelines and information for contributors.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Adding New Fractals](#adding-new-fractals)
4. [Code Style](#code-style)
5. [Testing](#testing)
6. [Documentation](#documentation)
7. [Pull Request Process](#pull-request-process)
8. [Release Process](#release-process)

## Getting Started

### Prerequisites

- **Swift**: 5.10 or later
- **Xcode**: 15.0 or later (for macOS development)
- **Platforms**: macOS 12.0+, iOS 15.0+
- **Dependencies**: swift-numerics package

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/fractal-generators.git
   cd fractal-generators
   ```
3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/original-owner/fractal-generators.git
   ```

## Development Setup

### Building the Package

```bash
# Build the package
swift build

# Run tests
swift test

# Build with specific configuration
swift build -c release
```

### Demo App Development

```bash
# Open the demo app in Xcode
open DemoApp/FractalsShowcase.xcodeproj

# Or build from command line
xcodebuild -project DemoApp/FractalsShowcase.xcodeproj -scheme FractalsShowcase build
```

### Package Dependencies

The package depends on:
- `swift-numerics` for complex number support
- `SwiftUI` for UI components
- `CoreGraphics` for image generation

## Adding New Fractals

### 1. Choose the Appropriate Protocol

Determine which protocol your fractal should implement:

- **`ImageFractalGenerator`**: For fractals that generate images (Mandelbrot, Julia)
- **`PathFractalGenerator`**: For fractals that generate paths (Sierpinski, Koch)
- **`PointFractalGenerator`**: For fractals that generate point clouds (Attractors)
- **`ProgressiveFractalGenerator`**: For fractals that support progressive rendering

### 2. Create the Generator File

Create a new file in `Sources/FractalGenerators/Generators/`:

```swift
//
//  YourFractalGenerator.swift
//  FractalGenerators
//
//  Created by Your Name 2021.
//

import Foundation
import SwiftUI
import CoreGraphics
import ComplexModule

/**
 * Your Fractal Name Generator
 *
 * Brief description of the fractal and its mathematical properties.
 *
 * Properties:
 * - Mathematical definition
 * - Fractal dimension
 * - Self-similarity properties
 * - Key characteristics
 */

struct YourFractalParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    // Add your specific parameters here
}

struct YourFractalGenerator: ImageFractalGenerator {
    func generate(with parameters: YourFractalParameters) -> CGImage {
        return generateImage(with: parameters)
    }
    
    func generateImage(with parameters: YourFractalParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        defer { data.deallocate() }
        
        // Your fractal generation algorithm here
        
        let context = CGContext(
            data: data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        return context!.makeImage()!
    }
    
    func generateAsync(with parameters: YourFractalParameters,
                      progress: @escaping @Sendable (Double) -> Void,
                      completion: @escaping @Sendable (CGImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.generateImage(with: parameters)
            completion(image)
        }
    }
}
```

### 3. Add to FractalFactory

Add a convenience method to `FractalFactory`:

```swift
// In FractalFactory.swift
static func createYourFractal(
    iterations: Int = 1000,
    size: CGSize = CGSize(width: 600, height: 600)
) -> GenericFractalView<YourFractalGenerator> {
    let generator = YourFractalGenerator()
    let parameters = YourFractalParameters(
        iterations: iterations,
        size: size
    )
    return GenericFractalView(generator: generator, parameters: parameters)
}
```

### 4. Add to FractalTypeEnum

Add your fractal to the enum in `FractalFactory.swift`:

```swift
enum FractalTypeEnum: CaseIterable {
    case mandelbrot
    case juliaSet
    // ... other cases
    case yourFractal
    
    var displayName: String {
        switch self {
        case .mandelbrot: return "Mandelbrot"
        case .juliaSet: return "Julia Set"
        // ... other cases
        case .yourFractal: return "Your Fractal"
        }
    }
    
    func createView() -> AnyView {
        switch self {
        case .mandelbrot: return AnyView(FractalFactory.createMandelbrot())
        case .juliaSet: return AnyView(FractalFactory.createJuliaSet())
        // ... other cases
        case .yourFractal: return AnyView(FractalFactory.createYourFractal())
        }
    }
}
```

### 5. Add Tests

Create tests in `Tests/FractalGeneratorsTests/`:

```swift
import XCTest
@testable import FractalGenerators

final class YourFractalGeneratorTests: XCTestCase {
    func testYourFractalGeneration() {
        let generator = YourFractalGenerator()
        let parameters = YourFractalParameters(
            iterations: 100,
            size: CGSize(width: 100, height: 100)
        )
        
        let image = generator.generate(with: parameters)
        
        XCTAssertNotNil(image)
        XCTAssertEqual(image.width, 100)
        XCTAssertEqual(image.height, 100)
    }
    
    func testYourFractalAsyncGeneration() {
        let expectation = XCTestExpectation(description: "Async generation")
        
        let generator = YourFractalGenerator()
        let parameters = YourFractalParameters(
            iterations: 100,
            size: CGSize(width: 100, height: 100)
        )
        
        generator.generateAsync(
            with: parameters,
            progress: { _ in },
            completion: { image in
                XCTAssertNotNil(image)
                expectation.fulfill()
            }
        )
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

### 6. Update Documentation

Update the documentation files:

- Add to `docs/FRACTAL_TYPES.md`
- Add examples to `docs/EXAMPLES.md`
- Update `docs/ARCHITECTURE.md` if needed

## Code Style

### Swift Style Guide

Follow the official Swift API Design Guidelines:

- Use clear, descriptive names
- Prefer composition over inheritance
- Use Swift's type system effectively
- Follow Swift naming conventions

### File Organization

```
Sources/FractalGenerators/
├── Core/
│   ├── FractalProtocols.swift
│   ├── GenericFractalView.swift
│   └── FractalFactory.swift
└── Generators/
    ├── MandelbrotGenerator.swift
    ├── JuliaSetGenerator.swift
    └── [YourFractalGenerator.swift]
```

### Code Comments

- Use comprehensive header comments for each generator
- Include mathematical definitions and properties
- Document complex algorithms
- Add usage examples in comments

### Error Handling

- Use Swift's error handling mechanisms
- Provide meaningful error messages
- Handle edge cases gracefully
- Validate input parameters

## Testing

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter YourFractalGeneratorTests

# Run with verbose output
swift test --verbose
```

### Test Coverage

- Test both synchronous and asynchronous generation
- Test with various parameter combinations
- Test edge cases and error conditions
- Test performance with large inputs

### Performance Testing

```swift
func testPerformance() {
    measure {
        let generator = YourFractalGenerator()
        let parameters = YourFractalParameters(
            iterations: 1000,
            size: CGSize(width: 400, height: 400)
        )
        _ = generator.generate(with: parameters)
    }
}
```

## Documentation

### Code Documentation

- Use Swift's documentation comments (`///`)
- Include parameter descriptions
- Provide usage examples
- Document mathematical properties

### API Documentation

- Keep public APIs stable
- Use semantic versioning
- Document breaking changes
- Provide migration guides

### User Documentation

- Update README.md for new features
- Add examples to EXAMPLES.md
- Update FRACTAL_TYPES.md for new fractals
- Keep ARCHITECTURE.md current

## Pull Request Process

### Before Submitting

1. **Test your changes**:
   ```bash
   swift test
   swift build
   ```

2. **Update documentation**:
   - Update relevant .md files
   - Add code comments
   - Update examples

3. **Check code style**:
   - Follow Swift style guidelines
   - Use consistent formatting
   - Remove debug code

### Pull Request Guidelines

1. **Create a descriptive title** and description
2. **Reference related issues** if applicable
3. **Include tests** for new functionality
4. **Update documentation** as needed
5. **Provide examples** of usage

### Review Process

- All PRs require review
- Address review comments promptly
- Keep PRs focused and manageable
- Respond to feedback constructively

## Release Process

### Versioning

Follow semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### Release Checklist

1. **Update version** in Package.swift
2. **Update CHANGELOG.md** with changes
3. **Run full test suite**:
   ```bash
   swift test
   swift build -c release
   ```
4. **Test demo app**:
   ```bash
   xcodebuild -project DemoApp/FractalsShowcase.xcodeproj -scheme FractalsShowcase build
   ```
5. **Create release tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

### Release Notes

Include in release notes:
- New features and improvements
- Bug fixes
- Breaking changes
- Migration guides
- Performance improvements

## Getting Help

### Questions and Issues

- Use GitHub Issues for bug reports
- Use GitHub Discussions for questions
- Check existing issues before creating new ones
- Provide minimal reproduction examples

### Community Guidelines

- Be respectful and inclusive
- Help others learn and contribute
- Share knowledge and experiences
- Follow the project's code of conduct

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors page
- Project documentation

Thank you for contributing to FractalGenerators! Your contributions help make this project better for everyone. 