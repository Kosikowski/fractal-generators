//
//  CantorSetGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Cantor Set Fractal Generator
 *
 * The Cantor Set is one of the most fundamental fractals in mathematics.
 * It's created by repeatedly removing the middle third of each line segment.
 *
 * Mathematical Foundation:
 * - Start with a line segment [0,1]
 * - Remove the middle third (1/3, 2/3)
 * - Repeat on the remaining segments [0,1/3] and [2/3,1]
 * - Continue recursively to the desired depth
 *
 * Properties:
 * - Fractal dimension = log(2)/log(3) ≈ 0.631
 * - Totally disconnected (no connected components)
 * - Perfect (every point is a limit point)
 * - Self-similar at all scales
 * - Has zero length but uncountably many points
 */

struct CantorSetParameters: FractalParameters {
    let iterations: Int
    let size: CGSize

    init(iterations: Int = 8, size: CGSize = CGSize(width: 600, height: 600)) {
        self.iterations = iterations
        self.size = size
    }
}

struct CantorSetGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let yCenter = Double(height) / 2.0
        let lineHeight = 20.0
        let spacing = 30.0

        var path = Path()

        // Generate Cantor set for each level
        for level in 0 ..< min(parameters.depth, 10) { // Limit to prevent overflow
            let segments = cantorSegments(level: level)
            let y = yCenter + Double(level) * spacing

            for segment in segments {
                let x1 = segment.start * Double(width)
                let x2 = segment.end * Double(width)

                path.move(to: CGPoint(x: x1, y: y))
                path.addLine(to: CGPoint(x: x2, y: y))
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

    private struct Segment {
        let start: Double
        let end: Double
    }

    private func cantorSegments(level: Int) -> [Segment] {
        if level == 0 {
            return [Segment(start: 0.0, end: 1.0)]
        }

        let previousSegments = cantorSegments(level: level - 1)
        var newSegments: [Segment] = []

        for segment in previousSegments {
            let length = segment.end - segment.start
            let third = length / 3.0

            // Add the first third
            newSegments.append(Segment(start: segment.start, end: segment.start + third))
            // Add the last third
            newSegments.append(Segment(start: segment.end - third, end: segment.end))
        }

        return newSegments
    }
}
