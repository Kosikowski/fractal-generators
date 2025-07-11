//
//  CoastlineGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Fractal Coastline/Mountain Generation
 *
 * This generator creates fractal coastlines or mountain profiles using the
 * midpoint displacement algorithm, a classic method for creating natural-looking
 * fractal terrain.
 *
 * Mathematical Foundation:
 * - Uses 1D midpoint displacement to create a fractal line
 * - Starts with a straight line between two endpoints
 * - Iteratively subdivides each segment and displaces the midpoint
 * - The displacement follows: midpoint = average + random(-range, range) * roughness
 * - Range decreases by a factor (typically 0.5) each iteration
 *
 * Algorithm:
 * 1. Initialize endpoints with fixed heights
 * 2. For each iteration:
 *    - Find midpoints of all current segments
 *    - Set midpoint height = average of endpoints + random displacement
 *    - Reduce the displacement range for next iteration
 *
 * Fractal Properties:
 * - Fractal dimension ≈ 1.5 (typical for coastlines)
 * - Self-similar detail at all scales
 * - Creates natural-looking terrain profiles
 * - The roughness parameter controls the jaggedness of the terrain
 *
 * Applications:
 * - Coastline generation (brown land, cyan water)
 * - Mountain range silhouettes
 * - Natural terrain elevation profiles
 */

struct CoastlineParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let roughness: Double

    init(iterations: Int = 1000, size: CGSize = CGSize(width: 600, height: 600), roughness: Double = 0.5) {
        self.iterations = iterations
        self.size = size
        self.roughness = roughness
    }
}

struct CoastlineGenerator: PathFractalGenerator {
    func generate(with parameters: CoastlineParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: CoastlineParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let maxPoints = Int(pow(2.0, Double(parameters.iterations))) + 1

        // Initialize height array
        var heights = Array(repeating: 0.0, count: maxPoints)
        heights[0] = Double(height) * 0.5 // Left edge
        heights[maxPoints - 1] = Double(height) * 0.5 // Right edge

        // Midpoint displacement algorithm
        var range = Double(height) * 0.5
        for i in 0 ..< parameters.iterations {
            let points = Int(pow(2.0, Double(i)))
            let step = (maxPoints - 1) / points

            for j in stride(from: 0, to: maxPoints - step, by: step) {
                let midIndex = j + step / 2
                let avg = (heights[j] + heights[j + step]) / 2.0
                heights[midIndex] = avg + Double.random(in: -range ... range) * parameters.roughness
            }
            range *= pow(0.5, 1.0) // Reduce range each iteration
        }

        // Create path
        var path = Path()
        path.move(to: CGPoint(x: 0, y: height))

        // Plot the fractal line
        for i in 0 ..< maxPoints {
            let x = Double(width) * Double(i) / Double(maxPoints - 1)
            let y = Double(height) - heights[i]
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()

        return path
    }

    func generateAsync(with parameters: CoastlineParameters,
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
}
