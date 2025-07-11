//
//  GingerbreadmanMapGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Gingerbreadman Map Fractal Generator
 *
 * The Gingerbreadman Map is a chaotic map defined by:
 *   x_{n+1} = 1 - y_n + |x_n|
 *   y_{n+1} = x_n
 *
 * Properties:
 * - Creates a distinctive "gingerbreadman" shape
 * - Demonstrates chaotic behavior with sensitive dependence on initial conditions
 * - Fractal dimension ≈ 1.26
 * - Self-similar at all scales
 */

struct GingerbreadmanMapParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let initial: CGPoint
    init(iterations: Int = 100_000, size: CGSize = CGSize(width: 600, height: 600), initial: CGPoint = CGPoint(x: 0.1, y: 0.1)) {
        self.iterations = iterations
        self.size = size
        self.initial = initial
    }
}

struct GingerbreadmanMapGenerator: PointFractalGenerator {
    typealias Parameters = GingerbreadmanMapParameters
    typealias Output = [CGPoint]

    func generate(with parameters: GingerbreadmanMapParameters) -> [CGPoint] {
        generatePoints(with: parameters)
    }

    func generateAsync(with parameters: GingerbreadmanMapParameters, progress _: @escaping (Double) -> Void, completion: @escaping ([CGPoint]) -> Void) {
        completion(generate(with: parameters))
    }

    func generatePoints(with parameters: GingerbreadmanMapParameters) -> [CGPoint] {
        var points: [CGPoint] = []
        var x = parameters.initial.x
        var y = parameters.initial.y
        let w = parameters.size.width
        let h = parameters.size.height
        let scale = min(w, h) / 4.0
        let offsetX = w / 2.0
        let offsetY = h / 2.0
        for _ in 0 ..< parameters.iterations {
            let x1 = 1 - y + abs(x)
            let y1 = x
            let px = x1 * scale + offsetX
            let py = y1 * scale + offsetY
            points.append(CGPoint(x: px, y: py))
            x = x1
            y = y1
        }
        return points
    }
}
