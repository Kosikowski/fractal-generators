//
//  FractalProtocols.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import RealModule
import CoreGraphics
import Foundation
import SwiftUI

// MARK: - Core Protocols

/// Base protocol for all fractal generators
protocol FractalGenerator {
    associatedtype Parameters: FractalParameters
    associatedtype Output

    func generate(with parameters: Parameters) -> Output
    func generateAsync(with parameters: Parameters,
                       progress: @escaping @Sendable (Double) -> Void,
                       completion: @escaping @Sendable (Output) -> Void)
}

/// Base protocol for fractal parameters
protocol FractalParameters {
    var iterations: Int { get }
    var size: CGSize { get }
}

/// Protocol for image-based fractals (like Mandelbrot, Julia)
protocol ImageFractalGenerator: FractalGenerator where Output == CGImage {
    func generateImage(with parameters: Parameters) -> CGImage
}

/// Protocol for path-based fractals (like Sierpinski, Koch)
protocol PathFractalGenerator: FractalGenerator where Output == Path {
    func generatePath(with parameters: Parameters) -> Path
}

/// Protocol for point-based fractals (like attractors)
protocol PointFractalGenerator: FractalGenerator where Output == [CGPoint] {
    func generatePoints(with parameters: Parameters) -> [CGPoint]
}

/// Protocol for progressive rendering fractals
protocol ProgressiveFractalGenerator: FractalGenerator {
    func generateProgressive(with parameters: Parameters,
                             onProgress: @escaping @Sendable (CGImage, Double) -> Void)
}

// MARK: - Parameter Structures

/// Base parameters for all fractals
struct BaseFractalParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let colorPalette: [Color]

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         colorPalette: [Color] = [])
    {
        self.iterations = iterations
        self.size = size
        self.colorPalette = colorPalette
    }
}

/// Parameters for complex plane fractals (Mandelbrot, Julia)
struct ComplexPlaneParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let viewRect: ComplexRect
    let blockiness: Double
    let colorPalette: [Color]

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         viewRect: ComplexRect,
         blockiness: Double = 0.5,
         colorPalette: [Color] = [])
    {
        self.iterations = iterations
        self.size = size
        self.viewRect = viewRect
        self.blockiness = blockiness
        self.colorPalette = colorPalette
    }
}

/// Parameters for attractor fractals (Lorenz, Rossler, etc.)
struct AttractorParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let dt: Double
    let initialConditions: [Double]
    let scale: Double
    let colorPalette: [Color]

    init(iterations: Int = 10000,
         size: CGSize = CGSize(width: 600, height: 600),
         dt: Double = 0.01,
         initialConditions: [Double] = [0.1, 0.0, 0.0],
         scale: Double = 15.0,
         colorPalette: [Color] = [])
    {
        self.iterations = iterations
        self.size = size
        self.dt = dt
        self.initialConditions = initialConditions
        self.scale = scale
        self.colorPalette = colorPalette
    }
}

/// Parameters for IFS (Iterated Function System) fractals
struct IFSParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let transformations: [IFSTransformation]
    let colorPalette: [Color]

    init(iterations: Int = 50000,
         size: CGSize = CGSize(width: 500, height: 600),
         transformations: [IFSTransformation],
         colorPalette: [Color] = [])
    {
        self.iterations = iterations
        self.size = size
        self.transformations = transformations
        self.colorPalette = colorPalette
    }
}

/// Parameters for recursive fractals (Sierpinski, Koch, etc.)
struct RecursiveFractalParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let depth: Int
    let colorPalette: [Color]

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         depth: Int = 6,
         colorPalette: [Color] = [])
    {
        self.iterations = iterations
        self.size = size
        self.depth = depth
        self.colorPalette = colorPalette
    }
}

// MARK: - Supporting Structures

/// Defines a rectangular area in the complex plane
public struct ComplexRect {
    public var topLeft: Complex<Double>
    public var bottomRight: Complex<Double>

    public init(_ topLeft: Complex<Double>, _ bottomRight: Complex<Double>) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }
}

/// Transformation for IFS fractals
struct IFSTransformation {
    let probability: Double
    let matrix: [[Double]]
    let translation: [Double]

    init(probability: Double, matrix: [[Double]], translation: [Double]) {
        self.probability = probability
        self.matrix = matrix
        self.translation = translation
    }
}

// MARK: - Color Utilities

extension Color {
    /// Convert Color to RGB components (0-1 range)
    var rgbComponents: (red: Double, green: Double, blue: Double, alpha: Double) {
        // Simplified conversion - in a real implementation you'd use UIColor/NSColor
        // This is a placeholder for the actual conversion
        return (0.5, 0.5, 0.5, 1.0)
    }
}

/// Utility for HSV to RGB conversion
enum ColorUtils {
    static func hsvToRgb(h: Double, s: Double, v: Double) -> (r: Double, g: Double, b: Double) {
        let c = v * s
        let x = c * (1 - abs((h * 6).truncatingRemainder(dividingBy: 2) - 1))
        let m = v - c

        let (r, g, b): (Double, Double, Double)
        switch Int(h * 6) % 6 {
        case 0: (r, g, b) = (c, x, 0)
        case 1: (r, g, b) = (x, c, 0)
        case 2: (r, g, b) = (0, c, x)
        case 3: (r, g, b) = (0, x, c)
        case 4: (r, g, b) = (x, 0, c)
        case 5: (r, g, b) = (c, 0, x)
        default: (r, g, b) = (0, 0, 0)
        }

        return (r + m, g + m, b + m)
    }
}
