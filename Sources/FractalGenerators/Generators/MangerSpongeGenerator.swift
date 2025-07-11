//
//  MangerSpongeGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Menger Sponge Fractal Generator
 *
 * The Menger Sponge is a 3D fractal that is a 3D analogue of the Sierpinski Carpet.
 * In 2D projection, it appears as a fractal pattern created by recursively
 * removing the center square from a square and repeating on the remaining squares.
 *
 * Mathematical Foundation:
 * - Start with a square
 * - Divide it into 9 equal squares (3×3 grid)
 * - Remove the center square
 * - Repeat the process on each of the remaining 8 squares
 * - The process continues recursively to the desired depth
 *
 * Properties:
 * - Fractal dimension = log(8)/log(3) ≈ 1.893
 * - Self-similar at all scales
 * - Has zero area but infinite perimeter
 * - Demonstrates how simple rules create complex geometric patterns
 */

struct MangerSpongeParameters: FractalParameters {
    let iterations: Int
    let size: CGSize

    init(iterations: Int = 4, size: CGSize = CGSize(width: 600, height: 600)) {
        self.iterations = iterations
        self.size = size
    }
}

struct MangerSpongeGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        return generatePath(with: parameters)
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let initialRect = CGRect(x: Double(width) * 0.1,
                                 y: Double(height) * 0.1,
                                 width: Double(width) * 0.8,
                                 height: Double(height) * 0.8)

        var path = Path()
        mengerSpongeRecursive(in: initialRect, depth: parameters.depth, path: &path)
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

    private func mengerSpongeRecursive(in rect: CGRect, depth: Int, path: inout Path) {
        if depth == 0 {
            path.addRect(rect)
        } else {
            let w = rect.width / 3
            let h = rect.height / 3

            for row in 0 ..< 3 {
                for col in 0 ..< 3 {
                    if row == 1 && col == 1 {
                        continue // Remove center square
                    }
                    let newRect = CGRect(
                        x: rect.origin.x + Double(col) * w,
                        y: rect.origin.y + Double(row) * h,
                        width: w,
                        height: h
                    )
                    mengerSpongeRecursive(in: newRect, depth: depth - 1, path: &path)
                }
            }
        }
    }
}
