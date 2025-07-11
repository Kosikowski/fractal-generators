//
//  TreeBranchingGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Fractal Tree Branching Generator
 *
 * This generator creates fractal trees using recursive branching patterns that
 * mimic natural tree growth. Each branch splits into two smaller branches
 * at a specified angle, creating a self-similar structure.
 *
 * Mathematical Foundation:
 * - Each branch splits into two child branches
 * - Child branches are rotated by ±θ from the parent direction
 * - Branch length decreases by a scaling factor at each level
 * - The process continues recursively until the desired depth
 * - Line width decreases to simulate natural tapering
 *
 * Properties:
 * - Self-similar structure at all scales
 * - Mimics natural tree growth patterns
 * - Demonstrates how simple rules create complex natural forms
 * - Shows hierarchical branching typical of biological systems
 */

struct TreeBranchingParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let branchAngle: Double
    let lengthShrink: Double
    let widthShrink: Double

    init(iterations: Int = 8,
         size: CGSize = CGSize(width: 600, height: 600),
         branchAngle: Double = .pi / 6, // 30 degrees
         lengthShrink: Double = 0.7, // 70% length reduction per branch
         widthShrink: Double = 0.8)
    { // 80% width reduction per branch
        self.iterations = iterations
        self.size = size
        self.branchAngle = branchAngle
        self.lengthShrink = lengthShrink
        self.widthShrink = widthShrink
    }
}

struct TreeBranchingGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let initialLength = Double(height) * 0.3

        var path = Path()

        // Start at bottom center
        let startX = Double(width) / 2
        let startY = Double(height)

        // Draw the tree
        drawBranch(path: &path,
                   x: startX,
                   y: startY,
                   length: initialLength,
                   angle: -.pi / 2, // Straight up
                   depth: parameters.depth,
                   width: 3.0,
                   parameters: parameters)

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

    private func drawBranch(path: inout Path,
                            x: Double, y: Double,
                            length: Double, angle: Double,
                            depth: Int, width: Double,
                            parameters: RecursiveFractalParameters)
    {
        if depth <= 0 {
            return
        }

        // Calculate end point
        let endX = x + cos(angle) * length
        let endY = y + sin(angle) * length

        // Draw the branch
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: endX, y: endY))

        // Draw left branch
        drawBranch(path: &path,
                   x: endX,
                   y: endY,
                   length: length * 0.7, // lengthShrink
                   angle: angle + .pi / 6, // branchAngle
                   depth: depth - 1,
                   width: width * 0.8, // widthShrink
                   parameters: parameters)

        // Draw right branch
        drawBranch(path: &path,
                   x: endX,
                   y: endY,
                   length: length * 0.7, // lengthShrink
                   angle: angle - .pi / 6, // branchAngle
                   depth: depth - 1,
                   width: width * 0.8, // widthShrink
                   parameters: parameters)
    }
}
