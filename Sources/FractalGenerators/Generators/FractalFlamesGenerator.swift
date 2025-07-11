//
//  FractalFlamesGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Fractal Flames Generator
 *
 * Fractal Flames create artistic, colorful fractal patterns using
 * variations and color mapping. They combine multiple transformations
 * with color functions to create stunning visual effects.
 *
 * Properties:
 * - Creates artistic, colorful patterns
 * - Uses variation functions
 * - Combines multiple transformations
 * - Demonstrates color mapping techniques
 */

struct FractalFlamesParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let numPoints: Int
    let numVariations: Int
    let colorSpeed: Double
    init(iterations: Int = 100, size: CGSize = CGSize(width: 600, height: 600), numPoints: Int = 100_000, numVariations: Int = 3, colorSpeed: Double = 0.1) {
        self.iterations = iterations
        self.size = size
        self.numPoints = numPoints
        self.numVariations = numVariations
        self.colorSpeed = colorSpeed
    }
}

struct FractalFlamesGenerator: ImageFractalGenerator {
    typealias Parameters = FractalFlamesParameters
    typealias Output = CGImage

    func generate(with parameters: FractalFlamesParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: FractalFlamesParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        completion(generate(with: parameters))
    }

    func generateImage(with parameters: FractalFlamesParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        // Initialize point
        var point = CGPoint(x: 0.5, y: 0.5)
        var color = 0.0

        // Create histogram for density estimation
        var histogram = Array(repeating: Array(repeating: 0, count: height), count: width)
        var maxDensity = 0

        // Generate points
        for _ in 0 ..< parameters.numPoints {
            // Apply random transformation
            let variation = Int.random(in: 0 ..< parameters.numVariations)
            point = applyVariation(point: point, variation: variation)

            // Update color
            color += parameters.colorSpeed
            if color > 1.0 { color -= 1.0 }

            // Map to image coordinates
            let x = Int((point.x + 2.0) * Double(width) / 4.0)
            let y = Int((point.y + 2.0) * Double(height) / 4.0)

            if x >= 0 && x < width && y >= 0 && y < height {
                histogram[x][y] += 1
                maxDensity = max(maxDensity, histogram[x][y])
            }
        }

        // Create image
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Fill background
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw points with color mapping
        for y in 0 ..< height {
            for x in 0 ..< width {
                let density = histogram[x][y]
                if density > 0 {
                    let normalizedDensity = Double(density) / Double(maxDensity)
                    let hue = normalizedDensity
                    let saturation = 1.0
                    let brightness = min(1.0, normalizedDensity * 3.0)

                    let color = CGColor(red: CGFloat(hue),
                                        green: CGFloat(saturation),
                                        blue: CGFloat(brightness),
                                        alpha: 1.0)

                    context.setFillColor(color)
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }

        return context.makeImage()!
    }

    private func applyVariation(point: CGPoint, variation: Int) -> CGPoint {
        let x = point.x
        let y = point.y
        let r = sqrt(x * x + y * y)
        let theta = atan2(y, x)

        switch variation {
        case 0:
            // Linear variation
            return CGPoint(x: x, y: y)
        case 1:
            // Sinusoidal variation
            return CGPoint(x: sin(x), y: sin(y))
        case 2:
            // Spherical variation
            let factor = 1.0 / (r + 0.0001)
            return CGPoint(x: x * factor, y: y * factor)
        case 3:
            // Swirl variation
            let factor = 1.0 / (r + 0.0001)
            return CGPoint(x: x * cos(theta) - y * sin(theta), y: x * sin(theta) + y * cos(theta))
        default:
            return point
        }
    }
}
