//
//  HenonAttractorGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Henon Attractor Fractal Generator
struct HenonAttractorGenerator: PointFractalGenerator {
    func generate(with parameters: AttractorParameters) -> [CGPoint] {
        return generatePoints(with: parameters)
    }

    func generatePoints(with parameters: AttractorParameters) -> [CGPoint] {
        let width = parameters.size.width
        let height = parameters.size.height
        let scale = 200.0
        let offsetX = Double(width) / 2
        let offsetY = Double(height) / 2
        let a = 1.4
        let b = 0.3
        var x = 0.0
        var y = 0.0
        var points: [CGPoint] = []
        // Warm-up
        for _ in 0 ..< 100 {
            let xNext = 1 - a * x * x + y
            y = b * x
            x = xNext
        }
        // Generate points
        for _ in 0 ..< parameters.iterations {
            let xNext = 1 - a * x * x + y
            let yNext = b * x
            let px = x * scale + offsetX
            let py = y * scale + offsetY
            if px >= 0 && px < Double(width) && py >= 0 && py < Double(height) {
                points.append(CGPoint(x: px, y: py))
            }
            x = xNext
            y = yNext
        }
        return points
    }

    func generateAsync(with parameters: AttractorParameters, progress _: @escaping (Double) -> Void, completion: @escaping ([CGPoint]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let points = self.generatePoints(with: parameters)
            DispatchQueue.main.async {
                completion(points)
            }
        }
    }
}
