//
//  Mandelbrot2Generator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import CoreGraphics
import Foundation
import SwiftUI

/**
 * Mandelbrot Set Implementation (Alternative)
 *
 * This is an alternative implementation of the Mandelbrot set using the new architecture.
 * The Mandelbrot set is the set of complex numbers c for which the function
 * f(z) = z² + c does not diverge when iterated from z = 0.
 *
 * Mathematical Foundation:
 * - Uses the iteration: z[n+1] = z[n]² + c
 * - z[0] = 0, c is the complex coordinate being tested
 * - Points where |z| > 2 escape to infinity
 * - Points that remain bounded form the Mandelbrot set
 * - The boundary exhibits infinite detail and self-similarity
 *
 * Properties:
 * - Fractal dimension of the boundary ≈ 2
 * - Self-similar at all scales
 * - Shows intricate detail in the boundary regions
 * - Demonstrates the beauty of complex dynamics
 */

struct Mandelbrot2Parameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let zoom: Double

    init(iterations: Int = 100,
         size: CGSize = CGSize(width: 600, height: 600),
         zoom: Double = 1.5)
    {
        self.iterations = iterations
        self.size = size
        self.zoom = zoom
    }
}

struct Mandelbrot2Generator: ImageFractalGenerator {
    func generate(with parameters: Mandelbrot2Parameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateImage(with parameters: Mandelbrot2Parameters) -> CGImage {
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
                let cx = (Double(x) - Double(width) / 2) / (Double(width) / parameters.zoom)
                let cy = (Double(y) - Double(height) / 2) / (Double(height) / parameters.zoom)
                let color = mandelbrotColor(cx: cx, cy: cy, iterations: parameters.iterations)

                let offset = (y * width + x) * 4
                data[offset] = UInt8(color.r * 255) // R
                data[offset + 1] = UInt8(color.g * 255) // G
                data[offset + 2] = UInt8(color.b * 255) // B
                data[offset + 3] = UInt8(color.a * 255) // A
            }
        }

        return context.makeImage()!
    }

    func generateAsync(with parameters: Mandelbrot2Parameters,
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

    private func mandelbrotColor(cx: Double, cy: Double, iterations: Int) -> (r: Double, g: Double, b: Double, a: Double) {
        var z = Complex(0.0, 0.0)
        let c = Complex(cx, cy)
        var iter = 0
        while iter < iterations, z.lengthSquared < 4.0 {
            z = z * z + c
            iter += 1
        }
        let colorFactor = Double(iter) / Double(iterations)
        let (r, g, b) = ColorUtils.hsvToRgb(h: colorFactor, s: 1.0, v: 1.0)
        return (r, g, b, 1.0)
    }
}
