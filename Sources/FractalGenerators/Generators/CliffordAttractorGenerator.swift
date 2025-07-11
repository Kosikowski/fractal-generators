//
//  CliffordAttractorGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Clifford Attractor Fractal Generator
 *
 * The Clifford Attractor is a strange attractor defined by:
 *   x_{n+1} = sin(a*y_n) + c*cos(a*x_n)
 *   y_{n+1} = sin(b*x_n) + d*cos(b*y_n)
 *
 * Properties:
 * - Produces a wide variety of intricate, chaotic patterns
 * - Parameters (a, b, c, d) control the shape
 * - Fractal dimension ≈ 2
 * - Self-similar at all scales
 */

struct CliffordAttractorParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let a: Double
    let b: Double
    let c: Double
    let d: Double
    let initial: CGPoint
    init(iterations: Int = 100_000, size: CGSize = CGSize(width: 600, height: 600), a: Double = -1.4, b: Double = 1.6, c: Double = 1.0, d: Double = 0.7, initial: CGPoint = CGPoint(x: 0, y: 0)) {
        self.iterations = iterations
        self.size = size
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.initial = initial
    }
}

struct CliffordAttractorGenerator: PointFractalGenerator {
    typealias Parameters = CliffordAttractorParameters
    typealias Output = [CGPoint]

    func generate(with parameters: CliffordAttractorParameters) -> [CGPoint] {
        generatePoints(with: parameters)
    }

    func generateAsync(with parameters: CliffordAttractorParameters, progress _: @escaping (Double) -> Void, completion: @escaping ([CGPoint]) -> Void) {
        completion(generate(with: parameters))
    }

    func generatePoints(with parameters: CliffordAttractorParameters) -> [CGPoint] {
        var points: [CGPoint] = []
        var x = parameters.initial.x
        var y = parameters.initial.y
        let w = parameters.size.width
        let h = parameters.size.height
        let scale = min(w, h) / 4.0
        let offsetX = w / 2.0
        let offsetY = h / 2.0
        for _ in 0 ..< parameters.iterations {
            let x1 = sin(parameters.a * y) + parameters.c * cos(parameters.a * x)
            let y1 = sin(parameters.b * x) + parameters.d * cos(parameters.b * y)
            let px = x1 * scale + offsetX
            let py = y1 * scale + offsetY
            points.append(CGPoint(x: px, y: py))
            x = x1
            y = y1
        }
        return points
    }
}
