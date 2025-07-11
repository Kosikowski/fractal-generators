//
//  BrownianMotionGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Brownian Motion Fractal Generator
struct BrownianMotionGenerator: PointFractalGenerator {
    let stepSize: CGFloat

    func generate(with parameters: RecursiveFractalParameters) -> [CGPoint] {
        return generatePoints(with: parameters)
    }

    func generatePoints(with parameters: RecursiveFractalParameters) -> [CGPoint] {
        var x = parameters.size.width / 2
        var y = parameters.size.height / 2
        var points: [CGPoint] = [CGPoint(x: x, y: y)]
        for _ in 0 ..< parameters.depth {
            let angle = Double.random(in: 0 ..< 2 * .pi)
            x += stepSize * CGFloat(cos(angle))
            y += stepSize * CGFloat(sin(angle))
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }

    func generateAsync(with parameters: RecursiveFractalParameters, progress _: @escaping (Double) -> Void, completion: @escaping ([CGPoint]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let points = self.generatePoints(with: parameters)
            DispatchQueue.main.async {
                completion(points)
            }
        }
    }
}
