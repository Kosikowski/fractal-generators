//
//  HeighwayDragonGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Heighway Dragon Curve Fractal Generator
 *
 * The Heighway Dragon is a variation of the Dragon Curve, discovered by
 * John Heighway in 1966. It's a space-filling fractal curve created
 * using an L-system with slightly different rules than the standard Dragon Curve.
 *
 * Mathematical Foundation:
 * - Uses an L-system with alphabet: {F, +, -, X, Y}
 * - Production rules:
 *   X → X+YF
 *   Y → FX-Y
 *
 * Where:
 * - F: Draw forward
 * - +: Turn right 90°
 * - -: Turn left 90°
 * - X, Y: Variables that get replaced by the rules
 *
 * Algorithm:
 * 1. Start with axiom "FX"
 * 2. Apply production rules iteratively
 * 3. Interpret the resulting string as drawing instructions
 *
 * Fractal Properties:
 * - Fractal dimension = 2 (space-filling)
 * - Self-similar at all scales
 * - Eventually tiles the plane
 * - Each iteration roughly doubles the number of segments
 *
 * The Heighway Dragon differs from the standard Dragon Curve in its
 * L-system rules, producing a slightly different folding pattern,
 * though both are space-filling curves.
 */

struct HeighwayDragonGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let scale = Double(width) / pow(2, Double(parameters.depth) / 2) * 0.8 // Adjusted scaling

        // Generate the L-system string
        var sequence = "FX"
        for _ in 0 ..< parameters.depth {
            sequence = applyHeighwayRules(to: sequence)
        }

        // Drawing parameters
        let centerX = Double(width) / 2
        let centerY = Double(height) / 2
        var x = centerX
        var y = centerY
        var angle = 0.0

        var path = Path()
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
                angle += .pi / 2 // 90 degrees clockwise
            case "-":
                angle -= .pi / 2 // 90 degrees counterclockwise
            default:
                continue
            }
        }

        return path
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

    // Apply L-system production rules for Heighway Dragon
    private func applyHeighwayRules(to input: String) -> String {
        var result = ""
        for char in input {
            switch char {
            case "X":
                result += "X+YF"
            case "Y":
                result += "FX-Y"
            default:
                result.append(char)
            }
        }
        return result
    }
}
