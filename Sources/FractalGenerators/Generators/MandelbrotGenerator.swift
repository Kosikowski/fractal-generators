//
//  MandelbrotGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import CoreGraphics
import Foundation
import SwiftUI

/// Mandelbrot Set Fractal Generator
///
/// The Mandelbrot set is one of the most famous fractals, defined as the set of
/// complex numbers c for which the function f(z) = z² + c does not diverge when
/// iterated from z = 0.
///
/// Mathematical Foundation:
/// - Uses the iteration: z[n+1] = z[n]² + c
/// - z[0] = 0, c is the complex coordinate being tested
/// - Points where |z| > 2 escape to infinity
/// - Points that remain bounded form the Mandelbrot set
/// - The boundary exhibits infinite detail and self-similarity
struct MandelbrotGenerator: ImageFractalGenerator, ProgressiveFractalGenerator {
    func generate(with parameters: ComplexPlaneParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateImage(with parameters: ComplexPlaneParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            fatalError("Failed to create CGContext")
        }

        let data = context.data!.assumingMemoryBound(to: UInt8.self)

        for y in 0 ..< height {
            for x in 0 ..< width {
                let complexPoint = viewCoordinatesToComplex(
                    x: Double(x),
                    y: Double(y),
                    rect: parameters.size,
                    viewRect: parameters.viewRect
                )
                let iterationCount = computeMandelbrotIterations(
                    complexPoint,
                    maxIterations: parameters.iterations
                )
                let color = colorFromIteration(
                    iterationCount,
                    maxIterations: parameters.iterations,
                    colorPalette: parameters.colorPalette
                )

                let pixelIndex = (y * width + x) * 4
                data[pixelIndex] = UInt8(color.red * 255) // R
                data[pixelIndex + 1] = UInt8(color.green * 255) // G
                data[pixelIndex + 2] = UInt8(color.blue * 255) // B
                data[pixelIndex + 3] = UInt8(color.alpha * 255) // A
            }
        }

        return context.makeImage()!
    }

    func generateProgressive(with parameters: ComplexPlaneParameters,
                             onProgress: @escaping (CGImage, Double) -> Void)
    {
        // Start with low resolution and progressively increase
        let maxResolution = Int(min(parameters.size.width, parameters.size.height))
        let steps = 4
        let resolutionStep = maxResolution / steps

        for step in 1 ... steps {
            let currentResolution = resolutionStep * step
            let currentSize = CGSize(width: currentResolution, height: currentResolution)
            let currentParameters = ComplexPlaneParameters(
                iterations: parameters.iterations,
                size: currentSize,
                viewRect: parameters.viewRect,
                blockiness: parameters.blockiness,
                colorPalette: parameters.colorPalette
            )

            let image = generateImage(with: currentParameters)
            let progress = Double(step) / Double(steps)

            DispatchQueue.main.async {
                onProgress(image, progress)
            }
        }
    }

    func generateAsync(with parameters: ComplexPlaneParameters,
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

    // MARK: - Private Methods

    private func viewCoordinatesToComplex(x: Double, y: Double, rect: CGSize, viewRect: ComplexRect) -> Complex<Double> {
        let tl = viewRect.topLeft
        let br = viewRect.bottomRight
        let real = tl.real + (x / rect.width) * (br.real - tl.real)
        let imaginary = tl.imaginary + (y / rect.height) * (br.imaginary - tl.imaginary)
        return Complex(real, imaginary)
    }

    private func computeMandelbrotIterations(_ c: Complex<Double>, maxIterations: Int) -> Int {
        var z = Complex<Double>(0.0, 0.0)
        for iteration in 0 ..< maxIterations {
            z = z * z + c
            if z.length > 2 {
                return iteration
            }
        }
        return maxIterations
    }

    private func colorFromIteration(_ iteration: Int, maxIterations: Int, colorPalette: [Color]) -> (red: Double, green: Double, blue: Double, alpha: Double) {
        if iteration >= maxIterations {
            return (0, 0, 0, 1) // Black for points in the set
        }

        if !colorPalette.isEmpty {
            let color = colorPalette[iteration % colorPalette.count]
            let components = color.rgbComponents
            return (components.red, components.green, components.blue, components.alpha)
        }

        // Default color scheme using HSV
        let normalized = Double(iteration) / Double(maxIterations)
        let (r, g, b) = ColorUtils.hsvToRgb(h: normalized, s: 1.0, v: 1.0)
        return (r, g, b, 1.0)
    }
}
