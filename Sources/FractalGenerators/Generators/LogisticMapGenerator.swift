//
//  LogisticMapGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Logistic Map Bifurcation Diagram Generator
 *
 * The Logistic Map is a classic example of chaos theory, defined by the equation:
 * x[n+1] = r * x[n] * (1 - x[n])
 * where r is a parameter and x[n] is the population at time n.
 *
 * Mathematical Foundation:
 * - For r < 3: converges to a fixed point
 * - For 3 ≤ r < 3.57: period-doubling bifurcations (2, 4, 8, ... cycles)
 * - For r > 3.57: chaotic behavior with periodic windows
 * - The bifurcation diagram shows stable values of x for each r
 *
 * Fractal Properties:
 * - Self-similar structure in chaotic regions
 * - Fractal dimension ≈ 0.538 in chaotic regime
 * - Period-doubling cascade creates fractal patterns
 */

struct LogisticMapParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let rMin: Double
    let rMax: Double

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         rMin: Double = 2.5,
         rMax: Double = 4.0)
    {
        self.iterations = iterations
        self.size = size
        self.rMin = rMin
        self.rMax = rMax
    }
}

struct LogisticMapGenerator: PointFractalGenerator {
    func generate(with parameters: LogisticMapParameters) -> [CGPoint] {
        return generatePoints(with: parameters)
    }

    func generatePoints(with parameters: LogisticMapParameters) -> [CGPoint] {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        var points: [CGPoint] = []

        let xInitial = 0.5 // Initial x value
        let transient = parameters.iterations / 2 // Skip initial iterations to avoid transients

        // Iterate over r values
        for rPixel in 0 ..< width {
            let r = parameters.rMin + (parameters.rMax - parameters.rMin) * Double(rPixel) / Double(width)
            var x = xInitial

            // Run iterations to reach stable behavior
            var values = Set<Double>()
            for i in 0 ..< parameters.iterations {
                x = r * x * (1 - x)
                if i >= transient {
                    // Record stable values
                    let scaledX = x * Double(height)
                    if scaledX >= 0 && scaledX < Double(height) {
                        values.insert(scaledX)
                    }
                }
            }

            // Add stable points for this r
            for xValue in values {
                points.append(CGPoint(x: Double(rPixel), y: Double(height) - xValue))
            }
        }

        return points
    }

    func generateAsync(with parameters: LogisticMapParameters,
                       progress _: @escaping (Double) -> Void,
                       completion: @escaping ([CGPoint]) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let points = self.generatePoints(with: parameters)
            DispatchQueue.main.async {
                completion(points)
            }
        }
    }
}
