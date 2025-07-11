//
//  SimplexNoiseGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Simplex Noise Fractal Generator
 *
 * Simplex Noise is an improved version of Perlin noise that creates
 * natural-looking terrain and textures. It's more efficient and has
 * fewer artifacts than Perlin noise.
 *
 * Properties:
 * - Creates smooth, continuous noise patterns
 * - Self-similar at different scales
 * - Useful for terrain generation and procedural textures
 * - Fractal dimension varies with octaves
 */

struct SimplexNoiseParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let scale: Double
    let octaves: Int
    let persistence: Double
    let lacunarity: Double
    init(iterations: Int = 100, size: CGSize = CGSize(width: 600, height: 600), scale: Double = 50.0, octaves: Int = 4, persistence: Double = 0.5, lacunarity: Double = 2.0) {
        self.iterations = iterations
        self.size = size
        self.scale = scale
        self.octaves = octaves
        self.persistence = persistence
        self.lacunarity = lacunarity
    }
}

struct SimplexNoiseGenerator: ImageFractalGenerator {
    typealias Parameters = SimplexNoiseParameters
    typealias Output = CGImage

    func generate(with parameters: SimplexNoiseParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: SimplexNoiseParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        completion(generate(with: parameters))
    }

    func generateImage(with parameters: SimplexNoiseParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Generate noise for each pixel
        for y in 0 ..< height {
            for x in 0 ..< width {
                let noiseValue = generateSimplexNoise(
                    x: Double(x) / parameters.scale,
                    y: Double(y) / parameters.scale,
                    octaves: parameters.octaves,
                    persistence: parameters.persistence,
                    lacunarity: parameters.lacunarity
                )

                // Normalize to 0-1 range
                let normalizedValue = (noiseValue + 1.0) / 2.0
                let colorValue = UInt8(normalizedValue * 255)

                let color = CGColor(red: CGFloat(colorValue) / 255.0,
                                    green: CGFloat(colorValue) / 255.0,
                                    blue: CGFloat(colorValue) / 255.0,
                                    alpha: 1.0)

                context.setFillColor(color)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        return context.makeImage()!
    }

    private func generateSimplexNoise(x: Double, y: Double, octaves: Int, persistence: Double, lacunarity: Double) -> Double {
        var amplitude = 1.0
        var frequency = 1.0
        var noise = 0.0
        var maxValue = 0.0

        for _ in 0 ..< octaves {
            noise += amplitude * simplexNoise2D(x: x * frequency, y: y * frequency)
            maxValue += amplitude
            amplitude *= persistence
            frequency *= lacunarity
        }

        return noise / maxValue
    }

    private func simplexNoise2D(x: Double, y: Double) -> Double {
        // Simplified Simplex Noise implementation
        // This is a basic version - full implementation would be more complex

        let F2 = 0.5 * (sqrt(3.0) - 1.0)
        let G2 = (3.0 - sqrt(3.0)) / 6.0

        let s = (x + y) * F2
        let i = floor(x + s)
        let j = floor(y + s)
        let t = (i + j) * G2

        let X0 = i - t
        let Y0 = j - t
        let x0 = x - X0
        let y0 = y - Y0

        // Determine which simplex we're in
        let i1 = x0 > y0 ? 1 : 0
        let j1 = x0 > y0 ? 0 : 1

        let x1 = x0 - Double(i1) + G2
        let y1 = y0 - Double(j1) + G2
        let x2 = x0 - 1.0 + 2.0 * G2
        let y2 = y0 - 1.0 + 2.0 * G2

        // Hash coordinates
        let n0 = hash(Int(i), Int(j))
        let n1 = hash(Int(i) + i1, Int(j) + j1)
        let n2 = hash(Int(i) + 1, Int(j) + 1)

        // Calculate noise contributions
        let t0 = 0.5 - x0 * x0 - y0 * y0
        let t1 = 0.5 - x1 * x1 - y1 * y1
        let t2 = 0.5 - x2 * x2 - y2 * y2

        var noise = 0.0

        if t0 > 0 {
            noise += t0 * t0 * t0 * t0 * grad(n0, x0, y0)
        }
        if t1 > 0 {
            noise += t1 * t1 * t1 * t1 * grad(n1, x1, y1)
        }
        if t2 > 0 {
            noise += t2 * t2 * t2 * t2 * grad(n2, x2, y2)
        }

        return noise * 70.0 // Scale factor
    }

    private func hash(_ i: Int, _ j: Int) -> Int {
        return (i * 73_856_093) ^ (j * 19_349_663)
    }

    private func grad(_ hash: Int, _ x: Double, _ y: Double) -> Double {
        let h = hash & 7
        let u = h < 4 ? x : y
        let v = h < 4 ? y : x
        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
    }
}
