//
//  BuddhabrotGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import CoreGraphics
import Foundation
import SwiftUI

/**
 * Buddhabrot Fractal Generator
 *
 * The Buddhabrot is a variation of the Mandelbrot set that tracks the trajectory
 * of points that escape the set, rather than coloring based on escape time.
 * The result resembles a seated Buddha figure.
 *
 * Mathematical Foundation:
 * - Uses the same iteration as Mandelbrot: z[n+1] = z[n]² + c
 * - Only tracks points c that escape (|z| > 2)
 * - Records the trajectory of z values during escape
 * - Accumulates these trajectories to create the image
 *
 * Properties:
 * - Shows the "shadow" of escaping points
 * - Creates organic, flowing patterns
 * - Demonstrates the relationship between chaos and order
 * - Named for its resemblance to a seated Buddha
 */

struct BuddhabrotParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let viewRect: ComplexRect
    let samples: Int
    let maxIterations: Int

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         viewRect: ComplexRect = ComplexRect(Complex(-2.0, 2.0), Complex(2.0, -2.0)),
         samples: Int = 100_000,
         maxIterations: Int = 100)
    {
        self.iterations = iterations
        self.size = size
        self.viewRect = viewRect
        self.samples = samples
        self.maxIterations = maxIterations
    }
}

struct BuddhabrotGenerator: ImageFractalGenerator {
    func generate(with parameters: BuddhabrotParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateImage(with parameters: BuddhabrotParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        // Create accumulation buffer
        var buffer = Array(repeating: Array(repeating: 0, count: height), count: width)

        // Generate random samples
        for _ in 0 ..< parameters.samples {
            let cx = Double.random(in: parameters.viewRect.topLeft.real ... parameters.viewRect.bottomRight.real)
            let cy = Double.random(in: min(parameters.viewRect.topLeft.imaginary, parameters.viewRect.bottomRight.imaginary) ... max(parameters.viewRect.topLeft.imaginary, parameters.viewRect.bottomRight.imaginary))
            let c = Complex(cx, cy)

            // Check if this point escapes
            var z = Complex(0.0, 0.0)
            var trajectory: [Complex<Double>] = []
            var escaped = false

            for _ in 0 ..< parameters.maxIterations {
                z = z * z + c
                trajectory.append(z)

                if z.lengthSquared > 4.0 {
                    escaped = true
                    break
                }
            }

            // If escaped, add trajectory to buffer
            if escaped {
                for point in trajectory {
                    let realRange = parameters.viewRect.bottomRight.real - parameters.viewRect.topLeft.real
                    let imagRange = parameters.viewRect.bottomRight.imaginary - parameters.viewRect.topLeft.imaginary

                    // Ensure we map coordinates correctly regardless of view rectangle orientation
                    let normalizedX = (point.real - parameters.viewRect.topLeft.real) / realRange
                    let normalizedY = (point.imaginary - parameters.viewRect.topLeft.imaginary) / imagRange

                    let x = Int(normalizedX * Double(width))
                    let y = Int(normalizedY * Double(height))

                    if x >= 0 && x < width && y >= 0 && y < height {
                        buffer[x][y] += 1
                    }
                }
            }
        }

        // Find maximum value for normalization
        let maxValue = buffer.flatMap { $0 }.max() ?? 1

        // Create image
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
                let intensity = Double(buffer[x][y]) / Double(maxValue)
                let color = buddhabrotColor(intensity: intensity)

                let offset = (y * width + x) * 4
                data[offset] = UInt8(color.r * 255) // R
                data[offset + 1] = UInt8(color.g * 255) // G
                data[offset + 2] = UInt8(color.b * 255) // B
                data[offset + 3] = UInt8(color.a * 255) // A
            }
        }

        return context.makeImage()!
    }

    func generateAsync(with parameters: BuddhabrotParameters,
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

    private func buddhabrotColor(intensity: Double) -> (r: Double, g: Double, b: Double, a: Double) {
        // Apply gamma correction and color mapping
        let gamma = 0.3
        let adjustedIntensity = pow(intensity, gamma)

        // Create a warm, golden color scheme (HSV)
        let hue = 0.1 // Golden yellow
        let saturation = 0.8
        let brightness = adjustedIntensity

        let (r, g, b) = ColorUtils.hsvToRgb(h: hue, s: saturation, v: brightness)
        return (r, g, b, 1.0)
    }
}
