//
//  PlasmaFractalGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Plasma Fractal Generator
 *
 * The Plasma Fractal is a procedural terrain generation technique that creates
 * natural-looking landscapes using the diamond-square algorithm with random noise.
 *
 * Mathematical Foundation:
 * - Uses the diamond-square algorithm on a 2^n + 1 grid
 * - Diamond step: sets center of each square to average of corners + random noise
 * - Square step: sets midpoints of edges to average of surrounding points + noise
 * - Noise amplitude decreases by a roughness factor each iteration
 *
 * Properties:
 * - Creates smooth, natural-looking terrain
 * - Self-similar at all scales
 * - Adjustable roughness controls terrain jaggedness
 * - Useful for procedural landscape generation
 */

struct PlasmaFractalParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let roughness: Double

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         roughness: Double = 0.5)
    {
        self.iterations = iterations
        self.size = size
        self.roughness = roughness
    }
}

struct PlasmaFractalGenerator: ImageFractalGenerator {
    func generate(with parameters: PlasmaFractalParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateImage(with parameters: PlasmaFractalParameters) -> CGImage {
        let size = Int(parameters.size.width)
        let dimension = (1 << Int(log2(Double(size - 1)))) + 1 // Ensure power of 2 plus 1 size
        var heightMap = Array(repeating: Array(repeating: Double(0), count: dimension), count: dimension)

        // Set initial corner values
        heightMap[0][0] = Double.random(in: 0 ... 1)
        heightMap[0][dimension - 1] = Double.random(in: 0 ... 1)
        heightMap[dimension - 1][0] = Double.random(in: 0 ... 1)
        heightMap[dimension - 1][dimension - 1] = Double.random(in: 0 ... 1)

        var stepSize = dimension - 1
        var scale = parameters.roughness

        while stepSize > 1 {
            let halfStep = stepSize / 2

            // Diamond step
            for x in stride(from: 0, to: dimension - 1, by: stepSize) {
                for y in stride(from: 0, to: dimension - 1, by: stepSize) {
                    let avg = (heightMap[x][y] +
                        heightMap[x + stepSize][y] +
                        heightMap[x][y + stepSize] +
                        heightMap[x + stepSize][y + stepSize]) / 4
                    heightMap[x + halfStep][y + halfStep] = avg + Double.random(in: -scale ... scale)
                }
            }

            // Square step
            for x in stride(from: 0, to: dimension, by: halfStep) {
                for y in stride(from: (x + halfStep) % stepSize, to: dimension, by: stepSize) {
                    var sum: Double = 0
                    var count: Double = 0

                    if x - halfStep >= 0 { sum += heightMap[x - halfStep][y]; count += 1 }
                    if x + halfStep < dimension { sum += heightMap[x + halfStep][y]; count += 1 }
                    if y - halfStep >= 0 { sum += heightMap[x][y - halfStep]; count += 1 }
                    if y + halfStep < dimension { sum += heightMap[x][y + halfStep]; count += 1 }

                    heightMap[x][y] = (sum / count) + Double.random(in: -scale ... scale)
                }
            }

            stepSize /= 2
            scale *= parameters.roughness
        }

        return generateImage(from: heightMap)
    }

    func generateAsync(with parameters: PlasmaFractalParameters,
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

    private func generateImage(from heightMap: [[Double]]) -> CGImage {
        let dimension = heightMap.count
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                width: dimension,
                                height: dimension,
                                bitsPerComponent: 8,
                                bytesPerRow: dimension * 4,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        let data = context.data!.assumingMemoryBound(to: UInt8.self)

        for x in 0 ..< dimension {
            for y in 0 ..< dimension {
                let intensity = heightMap[x][y]
                let hue = intensity
                let (r, g, b) = ColorUtils.hsvToRgb(h: hue, s: 1.0, v: 1.0)

                let offset = (y * dimension + x) * 4
                data[offset] = UInt8(r * 255) // R
                data[offset + 1] = UInt8(g * 255) // G
                data[offset + 2] = UInt8(b * 255) // B
                data[offset + 3] = UInt8(255) // A
            }
        }

        return context.makeImage()!
    }
}
