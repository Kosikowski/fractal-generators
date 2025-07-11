//
//  PeanoCurveGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Peano Curve Fractal Generator
 *
 * The Peano Curve is a classic space-filling curve, constructed recursively by subdividing a square into 9 smaller squares and connecting their centers in a specific order.
 *
 * Mathematical Foundation:
 * - At each recursion, subdivide each segment into 9 and connect in a continuous path
 * - The curve fills the entire 2D space as recursion depth increases
 *
 * Properties:
 * - Space-filling: covers the entire square
 * - Self-similar at all scales
 * - Fractal dimension = 2
 */

struct PeanoCurveParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let depth: Int
    init(depth: Int = 3, size: CGSize = CGSize(width: 600, height: 600)) {
        self.depth = depth
        iterations = depth
        self.size = size
    }
}

struct PeanoCurveGenerator: PathFractalGenerator {
    typealias Parameters = PeanoCurveParameters
    typealias Output = Path

    func generate(with parameters: PeanoCurveParameters) -> Path {
        generatePath(with: parameters)
    }

    func generateAsync(with parameters: PeanoCurveParameters, progress _: @escaping (Double) -> Void, completion: @escaping (Path) -> Void) {
        // No async needed for simple path
        completion(generate(with: parameters))
    }

    func generatePath(with parameters: PeanoCurveParameters) -> Path {
        var path = Path()
        let margin: CGFloat = 20
        let drawSize = CGSize(width: parameters.size.width - 2 * margin, height: parameters.size.height - 2 * margin)
        let start = CGPoint(x: margin, y: margin)
        drawPeano(depth: parameters.depth, rect: CGRect(origin: start, size: drawSize), path: &path)
        return path
    }

    private func drawPeano(depth: Int, rect: CGRect, path: inout Path) {
        if depth == 0 {
            // Draw a point at the center
            let center = CGPoint(x: rect.midX, y: rect.midY)
            if path.isEmpty {
                path.move(to: center)
            } else {
                path.addLine(to: center)
            }
            return
        }
        // Subdivide into 9 squares (3x3 grid)
        let w = rect.width / 3
        let h = rect.height / 3
        let order = [
            (0, 0), (0, 1), (0, 2),
            (1, 2), (1, 1), (1, 0),
            (2, 0), (2, 1), (2, 2),
        ]
        for (i, j) in order {
            let subRect = CGRect(x: rect.origin.x + CGFloat(i) * w, y: rect.origin.y + CGFloat(j) * h, width: w, height: h)
            drawPeano(depth: depth - 1, rect: subRect, path: &path)
        }
    }
}
