//
//  SierpinskiArrowheadGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Sierpinski Arrowhead Curve Fractal Generator
 *
 * The Sierpinski Arrowhead Curve is a space-filling curve that approximates
 * the Sierpinski Triangle. It's created using an L-system with specific
 * production rules that generate a continuous path outlining the triangle.
 *
 * Mathematical Foundation:
 * - Uses an L-system with alphabet: {F, +, -, X, Y}
 * - Production rules:
 *   X → YF+XF+Y
 *   Y → XF-YF-X
 * - F: Draw forward, +: Turn right 60°, -: Turn left 60°
 * - The curve converges to the Sierpinski Triangle as iterations increase
 *
 * Properties:
 * - Fractal dimension = log(3)/log(2) ≈ 1.585
 * - Self-similar at all scales
 * - Creates a continuous, unbroken path
 * - Unlike the point-based Sierpinski Triangle, this is a single curve
 */

struct SierpinskiArrowheadParameters: FractalParameters {
    let iterations: Int
    let size: CGSize

    init(iterations: Int = 6, size: CGSize = CGSize(width: 600, height: 600)) {
        self.iterations = iterations
        self.size = size
    }
}

struct SierpinskiArrowheadGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let scale = Double(width) * 0.5 * pow(0.5, Double(parameters.depth)) // Adjusted scaling

        var path = Path()

        // Generate the L-system string
        var sequence = "YF" // Start with YF (odd iterations use XF, but we adjust starting point)
        for _ in 0 ..< parameters.depth {
            sequence = applyArrowheadRules(to: sequence)
        }

        // Drawing parameters
        let startX = Double(width) / 4 // Shift left to fit triangle
        let startY = Double(height) * 0.75 // Start near bottom
        var x = startX
        var y = startY
        var angle = 0.0 // Initial direction upward

        path.move(to: CGPoint(x: x, y: y))

        // Interpret the L-system string
        for char in sequence {
            switch char {
            case "F":
                let newX = x + cos(angle) * scale
                let newY = y + sin(angle) * scale
                path.addLine(to: CGPoint(x: newX, y: newY))
                x = newX
                y = newY
            case "+":
                angle += .pi / 3 // 60 degrees clockwise
            case "-":
                angle -= .pi / 3 // 60 degrees counterclockwise
            default:
                continue
            }
        }

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

    // Apply L-system production rules for Sierpinski Arrowhead
    private func applyArrowheadRules(to input: String) -> String {
        var result = ""
        for char in input {
            switch char {
            case "X":
                result += "YF+XF+Y"
            case "Y":
                result += "XF-YF-X"
            case "F":
                result += "F"
            case "+":
                result += "+"
            case "-":
                result += "-"
            default:
                continue
            }
        }
        return result
    }
}
