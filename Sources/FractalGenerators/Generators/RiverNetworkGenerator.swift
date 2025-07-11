//
//  RiverNetworkGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Fractal River Network Generator
 *
 * This generator simulates the branching structure of river networks using recursive
 * branching patterns that mimic natural drainage systems and watersheds.
 *
 * Mathematical Foundation:
 * - Uses recursive branching with two tributaries per river segment
 * - Each tributary branches at ±45° angles with random variation
 * - Length and width decrease with each branching level
 * - The network flows downward, simulating gravity-driven drainage
 *
 * Properties:
 * - Fractal dimension typically between 1.5 and 2.0
 * - Self-similar branching at all scales
 * - Mimics natural river networks and drainage basins
 * - Demonstrates how simple rules create complex natural patterns
 */

struct RiverNetworkParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let branchAngle: Double
    let lengthShrink: Double
    let widthShrink: Double

    init(iterations: Int = 6,
         size: CGSize = CGSize(width: 600, height: 600),
         branchAngle: Double = .pi / 4, // 45 degrees for tributaries
         lengthShrink: Double = 0.75, // Tributaries are 75% of parent length
         widthShrink: Double = 0.8)
    { // Width reduces faster to mimic erosion
        self.iterations = iterations
        self.size = size
        self.branchAngle = branchAngle
        self.lengthShrink = lengthShrink
        self.widthShrink = widthShrink
    }
}

struct RiverNetworkGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let initialLength = Double(height) * 0.25

        var path = Path()

        // Start at top center (source of river)
        let startX = Double(width) / 2
        let startY = Double(height) * 0.1

        // Draw the river network
        drawRiver(path: &path,
                  x: startX,
                  y: startY,
                  length: initialLength,
                  angle: .pi / 2, // Downward flow
                  depth: parameters.depth,
                  width: 8.0) // Initial river width

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

    private func drawRiver(path: inout Path,
                           x: Double, y: Double,
                           length: Double, angle: Double,
                           depth: Int, width: Double)
    {
        if depth <= 0 || width < 1.0 {
            return
        }

        // Calculate end point
        let endX = x + cos(angle) * length
        let endY = y + sin(angle) * length

        // Draw the river segment
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: endX, y: endY))

        // Parameters for tributaries
        let branchAngle = Double.pi / 4 // 45 degrees for tributaries
        let lengthShrink = 0.75 // Tributaries are 75% of parent length
        let widthShrink = 0.8 // Width reduces faster to mimic erosion

        // Random variation to simulate natural irregularity
        let angleVariation = Double.random(in: -0.1 ... 0.1)
        let leftAngle = angle - branchAngle + angleVariation
        let rightAngle = angle + branchAngle - angleVariation

        // Draw left tributary
        drawRiver(path: &path,
                  x: endX,
                  y: endY,
                  length: length * lengthShrink,
                  angle: leftAngle,
                  depth: depth - 1,
                  width: width * widthShrink)

        // Draw right tributary
        drawRiver(path: &path,
                  x: endX,
                  y: endY,
                  length: length * lengthShrink,
                  angle: rightAngle,
                  depth: depth - 1,
                  width: width * widthShrink)
    }
}
