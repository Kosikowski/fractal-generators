//
//  SnowFlakeGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Koch Snowflake Fractal Generator
 *
 * The Koch Snowflake is a fractal curve created by applying the Koch curve
 * construction to each side of an equilateral triangle. It's one of the earliest
 * fractals discovered and demonstrates how simple rules create complex patterns.
 *
 * Mathematical Foundation:
 * - Start with an equilateral triangle
 * - Replace each side with a Koch curve
 * - The Koch curve rule: F → F+F--F+F
 * - Each iteration adds more detail to the boundary
 * - The process continues recursively to the desired depth
 *
 * Properties:
 * - Fractal dimension = log(4)/log(3) ≈ 1.262
 * - Self-similar at all scales
 * - Has finite area but infinite perimeter
 * - Exhibits perfect six-fold symmetry
 */

struct SnowFlakeParameters: FractalParameters {
    let iterations: Int
    let size: CGSize

    init(iterations: Int = 4, size: CGSize = CGSize(width: 600, height: 600)) {
        self.iterations = iterations
        self.size = size
    }
}

struct SnowFlakeGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        // Calculate scale based on iterations
        let scaleFactor = pow(1.0 / 3.0, Double(parameters.depth))
        let sideLength = Double(width) * 0.5 * scaleFactor

        var path = Path()

        // Generate Koch curve string
        var sequence = "F--F--F" // Initial equilateral triangle
        for _ in 0 ..< parameters.depth {
            sequence = applyKochRules(to: sequence)
        }

        // Drawing parameters
        let centerX = Double(width) / 2
        let centerY = Double(height) / 2
        var x = centerX + sideLength * cos(.pi / 2) // Start at top
        var y = centerY - sideLength * sin(.pi / 2)
        var angle = 0.0

        path.move(to: CGPoint(x: x, y: y))

        // Draw the snowflake
        for char in sequence {
            switch char {
            case "F":
                let newX = x + cos(angle) * sideLength
                let newY = y + sin(angle) * sideLength
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

    // Apply Koch curve L-system rules
    private func applyKochRules(to input: String) -> String {
        var result = ""
        for char in input {
            switch char {
            case "F":
                result += "F+F--F+F"
            default:
                result.append(char)
            }
        }
        return result
    }
}
