//
//  BoxCountingGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Box Counting Fractal Generator (Koch Snowflake path)
struct BoxCountingGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        let width = parameters.size.width
        let height = parameters.size.height
        let kochPath = kochSnowflakePath(iterations: parameters.depth, width: width, height: height)
        return kochPath
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        return generate(with: parameters)
    }

    func generateAsync(with parameters: RecursiveFractalParameters, progress _: @escaping (Double) -> Void, completion: @escaping (Path) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let path = self.generate(with: parameters)
            DispatchQueue.main.async {
                completion(path)
            }
        }
    }

    // Generate Koch Snowflake path using L-system
    private func kochSnowflakePath(iterations: Int, width: CGFloat, height: CGFloat) -> Path {
        let sideLength = Double(width) * 0.5 * pow(1.0 / 3.0, Double(iterations))
        var sequence = "F--F--F"
        for _ in 0 ..< iterations {
            sequence = sequence.replacingOccurrences(of: "F", with: "F+F--F+F")
        }
        let centerX = Double(width) / 2
        let centerY = Double(height) / 2
        var x = centerX + sideLength * cos(.pi / 2)
        var y = centerY - sideLength * sin(.pi / 2)
        var angle = 0.0
        var path = Path()
        path.move(to: CGPoint(x: x, y: y))
        for char in sequence {
            switch char {
            case "F":
                x += cos(angle) * sideLength
                y += sin(angle) * sideLength
                path.addLine(to: CGPoint(x: x, y: y))
            case "+":
                angle += .pi / 3
            case "-":
                angle -= .pi / 3
            default:
                continue
            }
        }
        path.closeSubpath()
        return path
    }
}
