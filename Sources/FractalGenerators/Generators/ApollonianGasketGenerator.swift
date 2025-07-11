//
//  ApollonianGasketGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Apollonian Gasket Fractal Generator
 *
 * The Apollonian Gasket is a fractal pattern formed by packing circles within circles.
 * It's based on the Apollonian Circle Theorem (also known as Soddy's Theorem).
 *
 * Mathematical Foundation:
 * - The fractal is created by recursively inscribing circles that are tangent to three existing circles
 * - For any three mutually tangent circles, there are exactly two circles tangent to all three
 * - The curvature k of a circle is defined as k = 1/r where r is the radius
 * - Descartes' Circle Theorem: (k₁ + k₂ + k₃ + k₄)² = 2(k₁² + k₂² + k₃² + k₄²)
 * - This allows us to calculate the radius of the fourth circle given three tangent circles
 *
 * The fractal exhibits self-similarity at all scales and has a fractal dimension
 * of approximately 1.3057, making it a space-filling fractal.
 */

struct ApollonianGasketGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let initialRadius = Double(width) * 0.35

        var combinedPath = Path()

        // Initial setup: three mutually tangent circles
        let centerX = Double(width) / 2
        let centerY = Double(height) / 2

        // Outer circle (circumcircle)
        let outerCircle = Circle(x: centerX, y: centerY, radius: initialRadius)
        combinedPath.addPath(createCirclePath(circle: outerCircle, size: parameters.size))

        // Calculate positions for three initial inner circles
        let innerRadius = initialRadius / (1 + sqrt(3.0))
        let offset = initialRadius - innerRadius

        let circle1 = Circle(x: centerX, y: centerY - offset, radius: innerRadius)
        let circle2 = Circle(x: centerX - offset * cos(.pi / 6), y: centerY + offset * sin(.pi / 6), radius: innerRadius)
        let circle3 = Circle(x: centerX + offset * cos(.pi / 6), y: centerY + offset * sin(.pi / 6), radius: innerRadius)

        combinedPath.addPath(createCirclePath(circle: circle1, size: parameters.size))
        combinedPath.addPath(createCirclePath(circle: circle2, size: parameters.size))
        combinedPath.addPath(createCirclePath(circle: circle3, size: parameters.size))

        // Recursively fill with smaller circles
        fillGasket(c1: circle1, c2: circle2, c3: circle3, depth: parameters.depth, path: &combinedPath, size: parameters.size)

        return combinedPath
    }

    func generateAsync(with parameters: RecursiveFractalParameters,
                       progress: @escaping (Double) -> Void,
                       completion: @escaping (Path) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let path = self.generatePath(with: parameters)
            DispatchQueue.main.async {
                progress(1.0)
                completion(path)
            }
        }
    }

    private struct Circle {
        let x: Double
        let y: Double
        let radius: Double
    }

    private func createCirclePath(circle: Circle, size _: CGSize) -> Path {
        let rect = CGRect(
            x: circle.x - circle.radius,
            y: circle.y - circle.radius,
            width: circle.radius * 2,
            height: circle.radius * 2
        )
        return Path(ellipseIn: rect)
    }

    private func complexSqrt(_ real: Double, _ imag: Double) -> (real: Double, imag: Double) {
        let r = sqrt(real * real + imag * imag)
        let theta = atan2(imag, real) / 2
        return (r * cos(theta), r * sin(theta))
    }

    private func fillGasket(c1: Circle, c2: Circle, c3: Circle, depth: Int, path: inout Path, size: CGSize) {
        guard depth > 0 else { return }

        let k1 = 1 / c1.radius
        let k2 = 1 / c2.radius
        let k3 = 1 / c3.radius

        // Curvature for new circle using Descartes' Circle Theorem
        let k4 = k1 + k2 + k3 + 2 * sqrt(k1 * k2 + k2 * k3 + k3 * k1)
        let newRadius = 1 / k4

        // Manual complex number calculations
        let cc_real = c1.x * k1 + c2.x * k2 + c3.x * k3
        let cc_imag = c1.y * k1 + c2.y * k2 + c3.y * k3

        // Calculate pairwise products for center computation
        let k12 = k1 * k2
        let k23 = k2 * k3
        let k31 = k3 * k1

        // Complex multiplication: (a+bi)(c+di) = (ac-bd) + (ad+bc)i
        let z12_real = c1.x * c2.x - c1.y * c2.y
        let z12_imag = c1.x * c2.y + c1.y * c2.x
        let z23_real = c2.x * c3.x - c2.y * c3.y
        let z23_imag = c2.x * c3.y + c2.y * c3.x
        let z31_real = c3.x * c1.x - c3.y * c1.y
        let z31_imag = c3.x * c1.y + c3.y * c1.x

        let term12_real = z12_real * k12
        let term12_imag = z12_imag * k12
        let term23_real = z23_real * k23
        let term23_imag = z23_imag * k23
        let term31_real = z31_real * k31
        let term31_imag = z31_imag * k31

        let dd_real = term12_real + term23_real + term31_real
        let dd_imag = term12_imag + term23_imag + term31_imag
        let ee = k1 + k2 + k3
        let ff = k1 * k2 + k2 * k3 + k3 * k1

        // Manual complex square root calculation
        let sqrt_dd_result = complexSqrt(dd_real, dd_imag)
        let sqrt_ff = sqrt(ff)

        let z4_real = (cc_real + 2 * sqrt_dd_result.real) / (ee + 2 * sqrt_ff)
        let z4_imag = (cc_imag + 2 * sqrt_dd_result.imag) / (ee + 2 * sqrt_ff)

        let newCircle = Circle(x: z4_real, y: z4_imag, radius: newRadius)

        if newRadius > 1 {
            path.addPath(createCirclePath(circle: newCircle, size: size))
            fillGasket(c1: c1, c2: c2, c3: newCircle, depth: depth - 1, path: &path, size: size)
            fillGasket(c1: c2, c2: c3, c3: newCircle, depth: depth - 1, path: &path, size: size)
            fillGasket(c1: c3, c2: c1, c3: newCircle, depth: depth - 1, path: &path, size: size)
        }
    }
}
