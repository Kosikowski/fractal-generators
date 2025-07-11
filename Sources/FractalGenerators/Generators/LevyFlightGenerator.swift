//
//  LevyFlightGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Lévy Flight Fractal Path Generator
 *
 * Lévy flights are random walks where the step lengths follow a heavy-tailed power-law distribution.
 * This results in a path with clusters of short steps and occasional long jumps, producing fractal patterns.
 *
 * Mathematical Foundation:
 * - Step length distribution: \( P(l) \propto l^{-\alpha} \), with 1 < α < 3
 * - Each step: random direction, power-law-distributed length
 * - The resulting path is self-similar and fractal
 *
 * Properties:
 * - Fractal dimension depends on α (for α=1.5, D ≈ 2)
 * - Models natural phenomena like animal foraging, diffusion, and turbulence
 * - Characterized by clusters and rare, long jumps
 */

struct LevyFlightParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let alpha: Double
    let minStep: Double
    let maxStep: Double

    init(iterations: Int = 1000,
         size: CGSize = CGSize(width: 600, height: 600),
         alpha: Double = 1.5,
         minStep: Double = 1.0,
         maxStep: Double = 180.0)
    {
        self.iterations = iterations
        self.size = size
        self.alpha = alpha
        self.minStep = minStep
        self.maxStep = maxStep
    }
}

struct LevyFlightGenerator: PathFractalGenerator {
    func generate(with parameters: LevyFlightParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: LevyFlightParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        var path = Path()

        // Start at center
        var x = Double(width) / 2
        var y = Double(height) / 2

        path.move(to: CGPoint(x: x, y: y))

        // Generate the Lévy Flight path
        for _ in 0 ..< parameters.iterations {
            // Random direction
            let angle = Double.random(in: 0 ..< 2 * .pi)

            // Lévy step length (approximated via power-law)
            let u = Double.random(in: 0 ... 1)
            let stepLength = parameters.minStep * pow(1.0 - u, -1.0 / parameters.alpha)
            let clampedStep = min(parameters.maxStep, max(parameters.minStep, stepLength))

            // Calculate new position
            let newX = x + cos(angle) * clampedStep
            let newY = y + sin(angle) * clampedStep

            // Draw line if within bounds
            if newX >= 0 && newX < Double(width) && newY >= 0 && newY < Double(height) {
                path.addLine(to: CGPoint(x: newX, y: newY))
                x = newX
                y = newY
            } else {
                // Reset to last valid position if out of bounds
                path.move(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }

    func generateAsync(with parameters: LevyFlightParameters,
                       progress _: @escaping (Double) -> Void,
                       completion: @escaping (Path) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let path = self.generatePath(with: parameters)
            DispatchQueue.main.async {
                completion(path)
            }
        }
    }
}
