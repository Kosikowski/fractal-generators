//
//  DragonCurveGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Dragon Curve Fractal Generator
///
/// The Dragon Curve is a space-filling fractal curve that was discovered by
/// NASA physicist John Heighway in 1966. It's created using an L-system
/// (Lindenmayer system) with string rewriting rules.
///
/// Mathematical Foundation:
/// - Uses an L-system with alphabet: {F, +, -, X, Y}
/// - Production rules:
///   X → X+YF+
///   Y → -FX-Y
///
/// Where:
/// - F: Draw forward
/// - +: Turn right 90°
/// - -: Turn left 90°
/// - X, Y: Variables that get replaced by the rules
///
/// Algorithm:
/// 1. Start with axiom "FX"
/// 2. Apply production rules iteratively
/// 3. Interpret the resulting string as drawing instructions
///
/// Fractal Properties:
/// - Fractal dimension = 2 (space-filling)
/// - Self-similar at all scales
/// - Eventually tiles the plane
/// - Each iteration roughly doubles the number of segments
struct DragonCurveGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generateDragonCurvePath(iterations: parameters.depth, size: parameters.size)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        return generate(with: parameters)
    }

    func generateAsync(with parameters: RecursiveFractalParameters,
                       progress _: @escaping (Double) -> Void,
                       completion: @escaping (Path) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let path = self.generate(with: parameters)
            DispatchQueue.main.async {
                completion(path)
            }
        }
    }

    private func generateDragonCurvePath(iterations: Int, size: CGSize) -> Path {
        // Generate the L-system string
        var sequence = "FX"
        for _ in 0 ..< iterations {
            sequence = applyDragonRules(to: sequence)
        }

        // Drawing parameters
        let scale = Double(min(size.width, size.height)) / pow(2, Double(iterations) / 2) * 0.5
        var x = Double(size.width) / 2
        var y = Double(size.height) / 2
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

    // Apply L-system production rules
    private func applyDragonRules(to input: String) -> String {
        var result = ""
        for char in input {
            switch char {
            case "X":
                result += "X+YF+"
            case "Y":
                result += "-FX-Y"
            default:
                result.append(char)
            }
        }
        return result
    }
}
