//
//  LightningPatternGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Fractal Lightning Pattern Generator
 *
 * This generator simulates the branching, self-similar structure of lightning using recursive
 * random branching, mimicking the natural fractal geometry of electrical discharges.
 *
 * Mathematical Foundation:
 * - Recursive branching with random angles and lengths
 * - Each branch splits at a random angle, with length and width decreasing at each level
 * - The process is repeated to a set recursion depth, creating a fractal pattern
 *
 * Properties:
 * - Fractal dimension typically between 1.2 and 1.7 (natural lightning)
 * - Self-similar at all scales
 * - Mimics the unpredictable, chaotic paths of real lightning
 */

struct LightningPatternParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let branchChance: Double
    let branchAngle: Double
    let lengthShrink: Double
    let widthShrink: Double

    init(iterations: Int = 8,
         size: CGSize = CGSize(width: 600, height: 600),
         branchChance: Double = 0.7,
         branchAngle: Double = .pi / 3,
         lengthShrink: Double = 0.6,
         widthShrink: Double = 0.7)
    {
        self.iterations = iterations
        self.size = size
        self.branchChance = branchChance
        self.branchAngle = branchAngle
        self.lengthShrink = lengthShrink
        self.widthShrink = widthShrink
    }
}

struct LightningPatternGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let initialLength = Double(height) * 0.3

        var path = Path()

        // Start at top center (cloud source)
        let startX = Double(width) / 2
        let startY = Double(height) * 0.1

        // Draw the lightning bolt
        drawLightning(path: &path,
                      x: startX,
                      y: startY,
                      length: initialLength,
                      angle: .pi / 2, // Downward initial direction
                      depth: parameters.depth,
                      width: 3.0) // Initial bolt width

        return path
    }

    func generateAsync(with parameters: RecursiveFractalParameters,
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

    private func drawLightning(path: inout Path,
                               x: Double, y: Double,
                               length: Double, angle: Double,
                               depth: Int, width: Double)
    {
        if depth <= 0 || length < 5.0 {
            return
        }

        // Calculate end point with random perturbation
        let perturbation = Double.random(in: -0.3 ... 0.3) // Chaotic deviation
        let adjustedAngle = angle + perturbation
        let endX = x + cos(adjustedAngle) * length
        let endY = y + sin(adjustedAngle) * length

        // Draw the main bolt segment
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: endX, y: endY))

        // Parameters for branching
        let branchChance = 0.7 // Probability of branching
        let branchAngle = Double.pi / 3 // 60 degrees for branches
        let lengthShrink = 0.6 // Branches are shorter
        let widthShrink = 0.7 // Branches are thinner

        // Randomly decide to branch
        if Double.random(in: 0 ... 1) < branchChance {
            let leftAngle = adjustedAngle - branchAngle + Double.random(in: -0.2 ... 0.2)
            drawLightning(path: &path,
                          x: endX,
                          y: endY,
                          length: length * lengthShrink,
                          angle: leftAngle,
                          depth: depth - 1,
                          width: width * widthShrink)

            let rightAngle = adjustedAngle + branchAngle + Double.random(in: -0.2 ... 0.2)
            drawLightning(path: &path,
                          x: endX,
                          y: endY,
                          length: length * lengthShrink,
                          angle: rightAngle,
                          depth: depth - 1,
                          width: width * widthShrink)
        } else {
            // Continue main path if no branch
            drawLightning(path: &path,
                          x: endX,
                          y: endY,
                          length: length * lengthShrink,
                          angle: adjustedAngle,
                          depth: depth - 1,
                          width: width * widthShrink)
        }
    }
}
