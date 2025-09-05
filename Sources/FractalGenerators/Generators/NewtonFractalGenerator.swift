//
//  NewtonFractalGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import CoreGraphics
import Foundation
import SwiftUI

/**
 * Newton Fractal Generator
 *
 * The Newton Fractal visualizes the convergence of Newton's method for finding
 * roots of complex polynomials. Each point is colored based on which root it
 * converges to and how quickly.
 *
 * Mathematical Foundation:
 * - Uses Newton's method: z[n+1] = z[n] - f(z[n])/f'(z[n])
 * - For f(z) = z³ - 1, the roots are 1, ω, ω² where ω = e^(2πi/3)
 * - Each point converges to one of the three roots
 * - Color indicates which root and convergence speed
 *
 * Properties:
 * - Shows basins of attraction for each root
 * - Fractal boundaries between basins
 * - Demonstrates chaos in iterative methods
 * - Educational for understanding Newton's method
 */

struct NewtonFractalParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let viewRect: ComplexRect
    let tolerance: Double

    init(iterations: Int = 100,
         size: CGSize = CGSize(width: 600, height: 600),
         viewRect: ComplexRect = ComplexRect(Complex(-2.0, 2.0), Complex(2.0, -2.0)),
         tolerance: Double = 1e-6)
    {
        self.iterations = iterations
        self.size = size
        self.viewRect = viewRect
        self.tolerance = tolerance
    }
}

struct NewtonFractalGenerator: ImageFractalGenerator {
    func generate(with parameters: NewtonFractalParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateImage(with parameters: NewtonFractalParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width * 4,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        let data = context.data!.assumingMemoryBound(to: UInt8.self)

        for x in 0 ..< width {
            for y in 0 ..< height {
                let realRange = parameters.viewRect.bottomRight.real - parameters.viewRect.topLeft.real
                let imagRange = parameters.viewRect.bottomRight.imaginary - parameters.viewRect.topLeft.imaginary
                let cx = parameters.viewRect.topLeft.real + realRange * Double(x) / Double(width)
                let cy = parameters.viewRect.topLeft.imaginary + imagRange * Double(y) / Double(height)
                let color = newtonColor(cx: cx, cy: cy, iterations: parameters.iterations, tolerance: parameters.tolerance)

                let offset = (y * width + x) * 4
                data[offset] = UInt8(color.r * 255) // R
                data[offset + 1] = UInt8(color.g * 255) // G
                data[offset + 2] = UInt8(color.b * 255) // B
                data[offset + 3] = UInt8(color.a * 255) // A
            }
        }

        return context.makeImage()!
    }

    func generateAsync(with parameters: NewtonFractalParameters,
                       progress _: @escaping (Double) -> Void,
                       completion: @escaping (CGImage) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.generateImage(with: parameters)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    private func newtonColor(cx: Double, cy: Double, iterations: Int, tolerance: Double) -> (r: Double, g: Double, b: Double, a: Double) {
        var z = Complex(cx, cy)
        var iter = 0

        // Newton's method for f(z) = z³ - 1
        // f'(z) = 3z²
        // z[n+1] = z[n] - (z[n]³ - 1)/(3z[n]²)

        while iter < iterations {
            let z3 = z * z * z
            let z2 = z * z
            let f = z3 - Complex(1.0, 0.0) // f(z) = z³ - 1
            let df = Complex(3.0, 0.0) * z2 // f'(z) = 3z²

            if df.lengthSquared < tolerance {
                break
            }

            z = z - f / df
            iter += 1
        }

        // Determine which root it converged to
        let root1 = Complex(1.0, 0.0)
        let root2 = Complex(-0.5, sqrt(3.0) / 2.0)
        let root3 = Complex(-0.5, -sqrt(3.0) / 2.0)

        let dist1 = (z - root1).lengthSquared
        let dist2 = (z - root2).lengthSquared
        let dist3 = (z - root3).lengthSquared

        let minDist = min(dist1, min(dist2, dist3))

        var hue: Double
        if minDist == dist1 {
            hue = 0.0 // Red for root 1
        } else if minDist == dist2 {
            hue = 0.33 // Green for root 2
        } else {
            hue = 0.67 // Blue for root 3
        }

        let saturation = 1.0
        let brightness = 1.0 - Double(iter) / Double(iterations)

        let (r, g, b) = ColorUtils.hsvToRgb(h: hue, s: saturation, v: brightness)
        return (r, g, b, 1.0)
    }
}
