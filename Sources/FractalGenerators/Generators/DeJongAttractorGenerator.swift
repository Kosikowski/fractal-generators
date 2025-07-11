//
//  DeJongAttractorGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * De Jong Attractor Fractal Generator
 *
 * The De Jong Attractor is a strange attractor defined by:
 *   x_{n+1} = sin(a*y_n) - cos(b*x_n)
 *   y_{n+1} = sin(c*x_n) - cos(d*y_n)
 *
 * Properties:
 * - Produces a wide variety of intricate, chaotic patterns
 * - Parameters (a, b, c, d) control the shape
 * - Fractal dimension ≈ 2
 * - Self-similar at all scales
 */

struct DeJongAttractorParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let a: Double
    let b: Double
    let c: Double
    let d: Double
    let initial: CGPoint
    init(iterations: Int = 100_000, size: CGSize = CGSize(width: 600, height: 600), a: Double = 2.01, b: Double = -2.53, c: Double = 1.61, d: Double = -0.33, initial: CGPoint = CGPoint(x: 0, y: 0)) {
        self.iterations = iterations
        self.size = size
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.initial = initial
    }
}

struct DeJongAttractorGenerator: PointFractalGenerator {
    typealias Parameters = DeJongAttractorParameters
    typealias Output = [CGPoint]

    func generate(with parameters: DeJongAttractorParameters) -> [CGPoint] {
        generatePoints(with: parameters)
    }

    func generateAsync(with parameters: DeJongAttractorParameters, progress _: @escaping (Double) -> Void, completion: @escaping ([CGPoint]) -> Void) {
        completion(generate(with: parameters))
    }

    func generatePoints(with parameters: DeJongAttractorParameters) -> [CGPoint] {
        var points: [CGPoint] = []
        var x = parameters.initial.x
        var y = parameters.initial.y
        let w = parameters.size.width
        let h = parameters.size.height
        let scale = min(w, h) / 4.0
        let offsetX = w / 2.0
        let offsetY = h / 2.0
        for _ in 0 ..< parameters.iterations {
            let x1 = sin(parameters.a * y) - cos(parameters.b * x)
            let y1 = sin(parameters.c * x) - cos(parameters.d * y)
            let px = x1 * scale + offsetX
            let py = y1 * scale + offsetY
            points.append(CGPoint(x: px, y: py))
            x = x1
            y = y1
        }
        return points
    }
}
