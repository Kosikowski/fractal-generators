# Usage Examples and Tutorials

This document provides comprehensive examples and tutorials for using the FractalGenerators package.

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Parameter Customization](#parameter-customization)
3. [Async Generation](#async-generation)
4. [Custom Generators](#custom-generators)
5. [Interactive Examples](#interactive-examples)
6. [Performance Optimization](#performance-optimization)
7. [Advanced Patterns](#advanced-patterns)

## Basic Usage

### Simple Fractal Display

```swift
import SwiftUI
import FractalGenerators

struct SimpleFractalView: View {
    var body: some View {
        FractalFactory.createMandelbrot()
            .frame(width: 400, height: 400)
    }
}
```

### Multiple Fractals

```swift
struct FractalGalleryView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                FractalFactory.createMandelbrot()
                    .frame(height: 200)
                
                FractalFactory.createSierpinski(depth: 6)
                    .frame(height: 200)
                
                FractalFactory.createLorenzAttractor()
                    .frame(height: 200)
                
                FractalFactory.createKochSnowflake(depth: 4)
                    .frame(height: 200)
            }
            .padding()
        }
    }
}
```

## Parameter Customization

### Complex Plane Fractals

```swift
struct CustomMandelbrotView: View {
    @State private var iterations: Double = 1000
    @State private var zoomLevel: Double = 1.0
    
    var body: some View {
        VStack {
            FractalFactory.createMandelbrot(
                iterations: Int(iterations),
                viewRect: ComplexRect(
                    Complex(-2.1 * zoomLevel, 1.5 * zoomLevel),
                    Complex(1.0 * zoomLevel, -1.5 * zoomLevel)
                )
            )
            .frame(width: 400, height: 400)
            
            VStack {
                Text("Iterations: \(Int(iterations))")
                Slider(value: $iterations, in: 100...5000)
                
                Text("Zoom: \(zoomLevel, specifier: "%.2f")")
                Slider(value: $zoomLevel, in: 0.1...5.0)
            }
            .padding()
        }
    }
}
```

### Recursive Fractals

```swift
struct CustomSierpinskiView: View {
    @State private var depth: Double = 6
    @State private var size: CGSize = CGSize(width: 400, height: 400)
    
    var body: some View {
        VStack {
            FractalFactory.createSierpinski(depth: Int(depth))
                .frame(width: size.width, height: size.height)
            
            VStack {
                Text("Depth: \(Int(depth))")
                Slider(value: $depth, in: 1...10)
                
                Text("Size: \(Int(size.width))x\(Int(size.height))")
                Slider(value: Binding(
                    get: { size.width },
                    set: { size = CGSize(width: $0, height: $0) }
                ), in: 100...600)
            }
            .padding()
        }
    }
}
```

### Attractor Fractals

```swift
struct CustomAttractorView: View {
    @State private var iterations: Double = 10000
    @State private var dt: Double = 0.01
    @State private var scale: Double = 50.0
    
    var body: some View {
        VStack {
            FractalFactory.createLorenzAttractor(
                iterations: Int(iterations),
                dt: dt,
                scale: scale
            )
            .frame(width: 400, height: 400)
            
            VStack {
                Text("Iterations: \(Int(iterations))")
                Slider(value: $iterations, in: 1000...50000)
                
                Text("Time Step: \(dt, specifier: "%.3f")")
                Slider(value: $dt, in: 0.001...0.1)
                
                Text("Scale: \(scale, specifier: "%.1f")")
                Slider(value: $scale, in: 10...200)
            }
            .padding()
        }
    }
}
```

## Async Generation

### Progress Tracking

```swift
struct AsyncFractalView: View {
    @State private var image: CGImage?
    @State private var progress: Double = 0.0
    @State private var isGenerating = false
    
    var body: some View {
        VStack {
            if let image = image {
                Image(image, scale: 1.0, label: Text("Fractal"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 400)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 400, height: 400)
                    .overlay(
                        VStack {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                            Text("Generating... \(Int(progress * 100))%")
                        }
                    )
            }
            
            Button("Generate Mandelbrot") {
                generateFractal()
            }
            .disabled(isGenerating)
        }
    }
    
    private func generateFractal() {
        isGenerating = true
        progress = 0.0
        
        let generator = MandelbrotGenerator()
        let parameters = ComplexPlaneParameters(
            iterations: 2000,
            size: CGSize(width: 400, height: 400),
            viewRect: ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5)),
            blockiness: 0.5
        )
        
        generator.generateAsync(
            with: parameters,
            progress: { progressValue in
                DispatchQueue.main.async {
                    self.progress = progressValue
                }
            },
            completion: { result in
                DispatchQueue.main.async {
                    self.image = result
                    self.isGenerating = false
                }
            }
        )
    }
}
```

### Background Generation

```swift
struct BackgroundFractalView: View {
    @State private var fractalViews: [AnyView] = []
    @State private var isGenerating = false
    
    var body: some View {
        ZStack {
            // Background fractals
            ForEach(0..<fractalViews.count, id: \.self) { index in
                fractalViews[index]
                    .opacity(0.3)
                    .scaleEffect(1.0 + Double(index) * 0.1)
                    .rotationEffect(.degrees(Double(index) * 15))
            }
            
            // Main content
            VStack {
                Text("Fractal Background")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Button("Add Background Fractal") {
                    addBackgroundFractal()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            addBackgroundFractal()
        }
    }
    
    private func addBackgroundFractal() {
        guard !isGenerating else { return }
        isGenerating = true
        
        DispatchQueue.global(qos: .background).async {
            let generators = [
                FractalFactory.createMandelbrot(),
                FractalFactory.createJuliaSet(),
                FractalFactory.createBurningShip(),
                FractalFactory.createTricorn()
            ]
            
            let randomGenerator = generators.randomElement()!
            
            DispatchQueue.main.async {
                fractalViews.append(AnyView(randomGenerator))
                isGenerating = false
            }
        }
    }
}
```

## Custom Generators

### Creating a Custom Fractal

```swift
struct CustomFractalGenerator: ImageFractalGenerator {
    func generate(with parameters: ComplexPlaneParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        defer { data.deallocate() }
        
        for y in 0..<height {
            for x in 0..<width {
                let realX = parameters.viewRect.min.real + 
                    (parameters.viewRect.max.real - parameters.viewRect.min.real) * Double(x) / Double(width)
                let imagY = parameters.viewRect.min.imaginary + 
                    (parameters.viewRect.max.imaginary - parameters.viewRect.min.imaginary) * Double(y) / Double(height)
                
                let c = Complex(realX, imagY)
                let color = generateCustomFractal(c: c, maxIterations: parameters.iterations)
                
                let offset = (y * width + x) * 4
                data[offset] = UInt8(color.redComponent * 255)
                data[offset + 1] = UInt8(color.greenComponent * 255)
                data[offset + 2] = UInt8(color.blueComponent * 255)
                data[offset + 3] = UInt8(color.alphaComponent * 255)
            }
        }
        
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
    
    private func generateCustomFractal(c: Complex, maxIterations: Int) -> NSColor {
        var z = Complex.zero
        var iteration = 0
        
        while z.magnitude < 2.0 && iteration < maxIterations {
            z = z * z + c
            iteration += 1
        }
        
        if iteration == maxIterations {
            return .black
        } else {
            let normalized = Double(iteration) / Double(maxIterations)
            return NSColor(
                hue: normalized,
                saturation: 1.0,
                brightness: normalized,
                alpha: 1.0
            )
        }
    }
}

struct CustomFractalView: View {
    let generator = CustomFractalGenerator()
    let parameters = ComplexPlaneParameters(
        iterations: 1000,
        size: CGSize(width: 400, height: 400),
        viewRect: ComplexRect(Complex(-2.0, 1.5), Complex(2.0, -1.5)),
        blockiness: 0.5
    )
    
    var body: some View {
        GenericFractalView(generator: generator, parameters: parameters)
    }
}
```

## Interactive Examples

### Fractal Explorer

```swift
struct FractalExplorerView: View {
    @State private var selectedFractal: FractalTypeEnum = .mandelbrot
    @State private var iterations: Double = 1000
    @State private var depth: Double = 6
    @State private var showControls = true
    
    var body: some View {
        NavigationView {
            VStack {
                // Fractal display
                selectedFractal.createView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                withAnimation {
                                    showControls.toggle()
                                }
                            }
                    )
                
                // Controls
                if showControls {
                    VStack {
                        Picker("Fractal Type", selection: $selectedFractal) {
                            ForEach(FractalTypeEnum.allCases, id: \.self) { fractal in
                                Text(fractal.displayName).tag(fractal)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        if selectedFractal.isComplexPlane {
                            VStack {
                                Text("Iterations: \(Int(iterations))")
                                Slider(value: $iterations, in: 100...5000)
                            }
                            .padding(.horizontal)
                        } else if selectedFractal.isRecursive {
                            VStack {
                                Text("Depth: \(Int(depth))")
                                Slider(value: $depth, in: 1...10)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .background(Color(.systemBackground))
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Fractal Explorer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

### Parameter Animation

```swift
struct AnimatedFractalView: View {
    @State private var animationProgress: Double = 0.0
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            FractalFactory.createMandelbrot(
                iterations: 1500,
                viewRect: ComplexRect(
                    Complex(-2.1 + animationProgress * 0.5, 1.5),
                    Complex(1.0 + animationProgress * 0.5, -1.5)
                )
            )
            .frame(width: 400, height: 400)
            
            Button(isAnimating ? "Stop Animation" : "Start Animation") {
                if isAnimating {
                    isAnimating = false
                } else {
                    startAnimation()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func startAnimation() {
        isAnimating = true
        withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: true)) {
            animationProgress = 1.0
        }
    }
}
```

## Performance Optimization

### Caching Generated Fractals

```swift
class FractalCache {
    static let shared = FractalCache()
    private var cache: [String: CGImage] = [:]
    
    func getFractal(for key: String, generator: @escaping () -> CGImage) -> CGImage {
        if let cached = cache[key] {
            return cached
        }
        
        let image = generator()
        cache[key] = image
        return image
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

struct CachedFractalView: View {
    @State private var image: CGImage?
    
    var body: some View {
        VStack {
            if let image = image {
                Image(image, scale: 1.0, label: Text("Cached Fractal"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 400)
            } else {
                ProgressView("Loading cached fractal...")
            }
            
            Button("Load Cached") {
                loadCachedFractal()
            }
        }
        .onAppear {
            loadCachedFractal()
        }
    }
    
    private func loadCachedFractal() {
        let key = "mandelbrot_1000_400x400"
        
        image = FractalCache.shared.getFractal(for: key) {
            let generator = MandelbrotGenerator()
            let parameters = ComplexPlaneParameters(
                iterations: 1000,
                size: CGSize(width: 400, height: 400),
                viewRect: ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5)),
                blockiness: 0.5
            )
            return generator.generate(with: parameters)
        }
    }
}
```

### Progressive Rendering

```swift
struct ProgressiveFractalView: View {
    @State private var currentImage: CGImage?
    @State private var progress: Double = 0.0
    @State private var isGenerating = false
    
    var body: some View {
        VStack {
            if let image = currentImage {
                Image(image, scale: 1.0, label: Text("Progressive Fractal"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 400)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 400, height: 400)
            }
            
            if isGenerating {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                Text("Progress: \(Int(progress * 100))%")
            }
            
            Button("Generate Progressive") {
                generateProgressive()
            }
            .disabled(isGenerating)
        }
    }
    
    private func generateProgressive() {
        isGenerating = true
        progress = 0.0
        
        let generator = MandelbrotGenerator()
        let parameters = ComplexPlaneParameters(
            iterations: 2000,
            size: CGSize(width: 400, height: 400),
            viewRect: ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5)),
            blockiness: 0.5
        )
        
        generator.generateProgressive(
            with: parameters,
            onProgress: { image, progressValue in
                DispatchQueue.main.async {
                    self.currentImage = image
                    self.progress = progressValue
                }
            }
        )
    }
}
```

## Advanced Patterns

### Fractal Composition

```swift
struct FractalCompositionView: View {
    var body: some View {
        ZStack {
            // Background layer
            FractalFactory.createPlasmaFractal()
                .opacity(0.3)
                .blur(radius: 10)
            
            // Middle layer
            FractalFactory.createMandelbrot()
                .opacity(0.7)
                .blendMode(.multiply)
            
            // Foreground layer
            FractalFactory.createSierpinski(depth: 5)
                .opacity(0.9)
                .blendMode(.overlay)
        }
        .frame(width: 400, height: 400)
    }
}
```

### Fractal Animation Sequence

```swift
struct FractalAnimationSequence: View {
    @State private var currentIndex = 0
    @State private var isAnimating = false
    
    let fractals = [
        FractalFactory.createMandelbrot(),
        FractalFactory.createJuliaSet(),
        FractalFactory.createBurningShip(),
        FractalFactory.createTricorn(),
        FractalFactory.createSierpinski(depth: 6),
        FractalFactory.createKochSnowflake(depth: 4)
    ]
    
    var body: some View {
        VStack {
            fractals[currentIndex]
                .frame(width: 400, height: 400)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            
            Button(isAnimating ? "Stop" : "Start Animation") {
                if isAnimating {
                    isAnimating = false
                } else {
                    startAnimation()
                }
            }
        }
    }
    
    private func startAnimation() {
        isAnimating = true
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            guard isAnimating else {
                timer.invalidate()
                return
            }
            
            withAnimation(.easeInOut(duration: 1.0)) {
                currentIndex = (currentIndex + 1) % fractals.count
            }
        }
    }
}
```

These examples demonstrate the flexibility and power of the FractalGenerators package. You can combine these patterns to create complex, interactive fractal applications. 