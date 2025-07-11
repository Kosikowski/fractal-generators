//
//  RomanescoBroccoliGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Romanesco Broccoli Fractal Generator
 *
 * Romanesco broccoli exhibits a natural fractal structure with logarithmic spirals
 * and self-similar budding patterns. This generator simulates its fractal geometry.
 *
 * Mathematical Foundation:
 * - Uses the golden angle (≈137.5°) for spiral distribution
 * - Each bud spawns multiple smaller buds in a logarithmic spiral
 * - Buds scale down by a factor at each recursion level
 * - The pattern demonstrates phyllotaxis (natural spiral arrangements in plants)
 *
 * Properties:
 * - Self-similar structure at all scales
 * - Logarithmic spiral arrangement mimics natural phyllotaxis
 * - Demonstrates how simple mathematical rules create complex natural forms
 * - Shows the fractal nature of many biological structures
 */

struct RomanescoBroccoliParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let numBuds: Int
    let scaleFactor: Double
    let goldenAngle: Double

    init(iterations: Int = 5,
         size: CGSize = CGSize(width: 600, height: 600),
         numBuds: Int = 5,
         scaleFactor: Double = 0.7,
         goldenAngle: Double = .pi * (3 - sqrt(5)))
    { // ≈ 137.5°
        self.iterations = iterations
        self.size = size
        self.numBuds = numBuds
        self.scaleFactor = scaleFactor
        self.goldenAngle = goldenAngle
    }
}

struct RomanescoBroccoliGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let initialRadius = Double(width) * 0.15

        var path = Path()

        // Center of the broccoli
        let centerX = Double(width) / 2
        let centerY = Double(height) / 2

        // Draw the Romanesco structure
        drawBud(path: &path,
                x: centerX,
                y: centerY,
                radius: initialRadius,
                angle: 0,
                depth: parameters.depth)

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

    private func drawBud(path: inout Path,
                         x: Double, y: Double,
                         radius: Double, angle: Double, depth: Int)
    {
        if depth <= 0 || radius < 2.0 {
            return
        }

        // Draw current bud as an approximate cone (ellipse for simplicity)
        let budRect = CGRect(x: x - radius * 0.5,
                             y: y - radius,
                             width: radius,
                             height: radius * 2)
        path.addEllipse(in: budRect)

        // Parameters for spiral budding
        let goldenAngle = .pi * (3 - sqrt(5)) // ≈ 137.5°, the golden angle
        let scaleFactor = 0.7 // Size reduction for child buds
        let numBuds = 5 // Number of buds per level

        // Recursively draw smaller buds in a spiral
        for i in 0 ..< numBuds {
            let newAngle = angle + goldenAngle * Double(i)
            let newRadius = radius * scaleFactor
            let distance = radius * 1.2 // Distance from center for new buds

            let newX = x + cos(newAngle) * distance
            let newY = y + sin(newAngle) * distance

            drawBud(path: &path,
                    x: newX,
                    y: newY,
                    radius: newRadius,
                    angle: newAngle,
                    depth: depth - 1)
        }
    }
}
