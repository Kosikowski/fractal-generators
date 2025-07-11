//
//  PerliniNoiseGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Perlin Noise Fractal Generator
 *
 * Perlin noise is a gradient noise function that produces smooth, natural-looking
 * random patterns. It's widely used in computer graphics for terrain generation,
 * texture synthesis, and other procedural content.
 *
 * Mathematical Foundation:
 * - Uses a grid of random gradient vectors
 * - Interpolates between grid points using smoothstep functions
 * - The noise function is continuous and has no visible grid artifacts
 * - Multiple octaves can be combined to create fractal noise
 *
 * Properties:
 * - Smooth and continuous across all scales
 * - Self-similar when combined with multiple frequencies
 * - Useful for generating natural-looking textures and terrain
 */

struct PerlinNoiseParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let scale: Double

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         scale: Double = 50.0)
    {
        self.iterations = iterations
        self.size = size
        self.scale = scale
    }
}

struct PerlinNoiseGenerator: ImageFractalGenerator {
    func generate(with parameters: PerlinNoiseParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateImage(with parameters: PerlinNoiseParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        var noise = Array(repeating: Array(repeating: Double(0), count: width), count: height)

        for x in 0 ..< width {
            for y in 0 ..< height {
                let nx = Double(x) / Double(width) * parameters.scale
                let ny = Double(y) / Double(height) * parameters.scale
                noise[x][y] = perlin(x: nx, y: ny)
            }
        }

        return generateImage(from: noise)
    }

    func generateAsync(with parameters: PerlinNoiseParameters,
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

    private func perlin(x: Double, y: Double) -> Double {
        let x0 = Int(floor(x))
        let x1 = x0 + 1
        let y0 = Int(floor(y))
        let y1 = y0 + 1

        let sx = x - Double(x0)
        let sy = y - Double(y0)

        let n0 = dotGridGradient(ix: x0, iy: y0, x: x, y: y)
        let n1 = dotGridGradient(ix: x1, iy: y0, x: x, y: y)
        let ix0 = lerp(a: n0, b: n1, t: sx)

        let n2 = dotGridGradient(ix: x0, iy: y1, x: x, y: y)
        let n3 = dotGridGradient(ix: x1, iy: y1, x: x, y: y)
        let ix1 = lerp(a: n2, b: n3, t: sx)

        return lerp(a: ix0, b: ix1, t: sy) * 0.5 + 0.5
    }

    private func dotGridGradient(ix: Int, iy: Int, x: Double, y: Double) -> Double {
        let randomAngle = Double(ix * 374_761 + iy * 668_265_263).truncatingRemainder(dividingBy: 360.0) * .pi / 180.0
        let gradientX = cos(randomAngle)
        let gradientY = sin(randomAngle)
        let dx = x - Double(ix)
        let dy = y - Double(iy)
        return dx * gradientX + dy * gradientY
    }

    private func lerp(a: Double, b: Double, t: Double) -> Double {
        return a + t * (b - a)
    }

    private func generateImage(from noise: [[Double]]) -> CGImage {
        let width = noise.count
        let height = noise[0].count
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
                let intensity = noise[x][y]
                let gray = UInt8(intensity * 255)

                let offset = (y * width + x) * 4
                data[offset] = gray // R
                data[offset + 1] = gray // G
                data[offset + 2] = gray // B
                data[offset + 3] = 255 // A
            }
        }

        return context.makeImage()!
    }
}
