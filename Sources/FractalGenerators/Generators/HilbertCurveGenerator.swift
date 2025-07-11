//
//  HilbertCurveGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Hilbert Curve Fractal Generator
 *
 * The Hilbert Curve is a space-filling curve that visits every point in a square
 * grid in a specific order. It's a continuous fractal curve that demonstrates
 * how a 1D line can fill a 2D space.
 *
 * Mathematical Foundation:
 * - Uses recursive subdivision of the square into 4 quadrants
 * - Each quadrant is visited in a specific order (Hilbert pattern)
 * - The curve is self-similar at all scales
 * - Fractal dimension = 2 (fills the entire plane)
 *
 * Properties:
 * - Space-filling: visits every point in the grid
 * - Self-similar: same pattern at all scales
 * - Locality-preserving: nearby points in 1D are nearby in 2D
 * - Used in spatial indexing and data organization
 */

struct HilbertCurveParameters: FractalParameters {
    let iterations: Int
    let size: CGSize

    init(iterations: Int = 6, size: CGSize = CGSize(width: 600, height: 600)) {
        self.iterations = iterations
        self.size = size
    }
}

struct HilbertCurveGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let size = min(width, height)
        let margin = max(width, height) - size

        var path = Path()
        var points: [CGPoint] = []

        // Generate Hilbert curve points
        hilbertCurve(order: parameters.depth, size: size, points: &points)

        // Scale and center the curve
        let scale = Double(size) / pow(2.0, Double(parameters.depth))
        let offsetX = Double(margin) / 2.0
        let offsetY = Double(margin) / 2.0

        if !points.isEmpty {
            path.move(to: CGPoint(
                x: points[0].x * scale + offsetX,
                y: points[0].y * scale + offsetY
            ))

            for i in 1 ..< points.count {
                path.addLine(to: CGPoint(
                    x: points[i].x * scale + offsetX,
                    y: points[i].y * scale + offsetY
                ))
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

    private func hilbertCurve(order: Int, size: Int, points: inout [CGPoint]) {
        if order == 0 {
            points.append(CGPoint(x: 0, y: 0))
            return
        }

        let halfSize = size / 2
        let currentPoints = points.count

        // Generate the four quadrants in Hilbert order
        hilbertCurve(order: order - 1, size: halfSize, points: &points)

        // Transform points for the second quadrant
        let startIndex = currentPoints
        let endIndex = points.count
        for i in startIndex ..< endIndex {
            points[i] = CGPoint(x: points[i].y, y: points[i].x)
        }

        // Add the third and fourth quadrants
        hilbertCurve(order: order - 1, size: halfSize, points: &points)

        // Transform points for the third quadrant
        let thirdStart = points.count
        for i in startIndex ..< endIndex {
            points.append(CGPoint(x: points[i].x + Double(halfSize), y: points[i].y + Double(halfSize)))
        }

        // Transform points for the fourth quadrant
        for i in startIndex ..< endIndex {
            points.append(CGPoint(x: Double(halfSize) - points[i].y, y: Double(halfSize) - points[i].x))
        }
    }
}
