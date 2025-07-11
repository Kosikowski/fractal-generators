//
//  FBMGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Fractional Brownian Motion (fBm) Terrain Generation
 *
 * Fractional Brownian Motion is a mathematical model for generating
 * natural-looking fractal terrain. It's based on Brownian motion but
 * with controlled fractal properties.
 *
 * Mathematical Foundation:
 * - fBm is defined as: B_H(t) = ∫₀ᵗ (t-s)^(H-1/2) dB(s)
 * - H is the Hurst exponent (0 < H < 1)
 * - For terrain generation, we use the spectral synthesis method:
 *   f(x,y) = Σᵢ Aᵢ × noise(fᵢ × x, fᵢ × y)
 *
 * Where:
 * - Aᵢ = 2^(-H×i) (amplitude decay)
 * - fᵢ = 2ⁱ (frequency increase)
 * - noise() is a smooth noise function
 *
 * Parameters:
 * - H < 0.5: Rough, jagged surfaces (anti-persistent)
 * - H = 0.5: Standard Brownian motion
 * - H > 0.5: Smooth, persistent surfaces
 *
 * Fractal Properties:
 * - Fractal dimension = 3 - H
 * - Self-similar at all scales
 * - Creates realistic terrain with natural roughness
 * - Multiple octaves provide detail at different scales
 */

struct FBMParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let octaves: Int
    let hurst: Double

    init(iterations: Int = 1000, size: CGSize = CGSize(width: 600, height: 600), octaves: Int = 6, hurst: Double = 0.5) {
        self.iterations = iterations
        self.size = size
        self.octaves = octaves
        self.hurst = hurst
    }
}

struct FBMGenerator: ImageFractalGenerator {
    func generate(with parameters: FBMParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateImage(with parameters: FBMParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        // Initialize heightmap
        var heightmap = Array(repeating: Array(repeating: 0.0, count: width), count: height)

        // fBm parameters
        let lacunarity = 2.0 // Frequency multiplier per octave
        let gain = pow(2.0, -parameters.hurst) // Amplitude decay per octave

        // Generate noise layers
        for octave in 0 ..< parameters.octaves {
            let frequency = pow(lacunarity, Double(octave))
            let amplitude = pow(gain, Double(octave))

            for y in 0 ..< height {
                for x in 0 ..< width {
                    let nx = Double(x) / Double(width) * frequency
                    let ny = Double(y) / Double(height) * frequency
                    heightmap[y][x] += noise(x: nx, y: ny) * amplitude
                }
            }
        }

        // Create CGImage from heightmap
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue)
        else {
            return createDefaultImage(size: parameters.size)
        }

        // Normalize heightmap for coloring
        var minHeight = heightmap[0][0]
        var maxHeight = heightmap[0][0]
        for y in 0 ..< height {
            for x in 0 ..< width {
                minHeight = min(minHeight, heightmap[y][x])
                maxHeight = max(maxHeight, heightmap[y][x])
            }
        }

        // Draw as a colored heightmap
        for y in 0 ..< height {
            for x in 0 ..< width {
                let heightValue = (heightmap[y][x] - minHeight) / (maxHeight - minHeight)
                let color: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)

                if heightValue < 0.3 {
                    color = (0, 0, 255, 255) // Water (blue)
                } else if heightValue < 0.7 {
                    color = (0, 255, 0, 255) // Land (green)
                } else {
                    color = (139, 69, 19, 255) // Mountains (brown)
                }

                let offset = (y * width + x) * 4
                context.data?.advanced(by: offset).assumingMemoryBound(to: UInt8.self)[0] = color.r
                context.data?.advanced(by: offset + 1).assumingMemoryBound(to: UInt8.self)[0] = color.g
                context.data?.advanced(by: offset + 2).assumingMemoryBound(to: UInt8.self)[0] = color.b
                context.data?.advanced(by: offset + 3).assumingMemoryBound(to: UInt8.self)[0] = color.a
            }
        }

        guard let image = context.makeImage() else {
            return createDefaultImage(size: parameters.size)
        }

        return image
    }

    func generateAsync(with parameters: FBMParameters,
                       progress: @escaping (Double) -> Void,
                       completion: @escaping (CGImage) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.generateImage(with: parameters)
            DispatchQueue.main.async {
                progress(1.0)
                completion(image)
            }
        }
    }

    // Simple Perlin-like noise function (for demonstration)
    private func noise(x: Double, y: Double) -> Double {
        let n = Int(x * 12345.6789 + y * 98765.4321)
        let seed = Double(n & 0x7FFF_FFFF) / Double(0x7FFF_FFFF)
        return seed * 2.0 - 1.0 // Range [-1, 1]
    }

    private func createDefaultImage(size: CGSize) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: Int(size.width) * 4,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue)
        else {
            fatalError("Failed to create CGContext")
        }

        // Fill with a default color
        context.setFillColor(CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        guard let image = context.makeImage() else {
            fatalError("Failed to create CGImage")
        }

        return image
    }
}
