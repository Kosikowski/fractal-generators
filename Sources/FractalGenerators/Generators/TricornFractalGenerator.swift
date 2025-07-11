//
//  TricornFractalGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import CoreGraphics
import Foundation
import SwiftUI

/**
 * Tricorn Fractal (Mandelbar Set) Generator
 *
 * The Tricorn Fractal is a variation of the Mandelbrot set that uses the
 * complex conjugate in the iteration: z[n+1] = z̄[n]² + c
 * where z̄ is the complex conjugate of z.
 *
 * Mathematical Foundation:
 * - Uses the iteration: z[n+1] = z̄[n]² + c
 * - z̄ = a - bi (complex conjugate of z = a + bi)
 * - Points where |z| > 2 escape to infinity
 * - Creates a distinctive three-lobed structure
 *
 * Properties:
 * - Symmetrical about the real axis
 * - Three main lobes (hence "tricorn")
 * - Fractal dimension ≈ 2 at the boundary
 * - Demonstrates how small changes in iteration create vastly different patterns
 */

struct TricornFractalParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let viewRect: ComplexRect
    let blockiness: Double

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         viewRect: ComplexRect = ComplexRect(Complex(-2.0, 1.5), Complex(2.0, -1.5)),
         blockiness: Double = 0.5)
    {
        self.iterations = iterations
        self.size = size
        self.viewRect = viewRect
        self.blockiness = blockiness
    }
}

struct TricornFractalGenerator: ImageFractalGenerator {
    func generate(with parameters: TricornFractalParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateImage(with parameters: TricornFractalParameters) -> CGImage {
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
                let color = tricornColor(cx: cx, cy: cy, iterations: parameters.iterations)

                let offset = (y * width + x) * 4
                data[offset] = UInt8(color.redComponent * 255) // R
                data[offset + 1] = UInt8(color.greenComponent * 255) // G
                data[offset + 2] = UInt8(color.blueComponent * 255) // B
                data[offset + 3] = UInt8(color.alphaComponent * 255) // A
            }
        }

        return context.makeImage()!
    }

    func generateAsync(with parameters: TricornFractalParameters,
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

    private func tricornColor(cx: Double, cy: Double, iterations: Int) -> NSColor {
        var z = Complex(0.0, 0.0)
        let c = Complex(cx, cy)
        var iter = 0

        while iter < iterations && z.lengthSquared < 4.0 {
            // Tricorn iteration: z = z̄² + c
            let conjugate = Complex(z.real, -z.imaginary) // Complex conjugate
            z = conjugate * conjugate + c
            iter += 1
        }

        let colorFactor = CGFloat(iter) / CGFloat(iterations)
        return NSColor(hue: colorFactor, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
}
