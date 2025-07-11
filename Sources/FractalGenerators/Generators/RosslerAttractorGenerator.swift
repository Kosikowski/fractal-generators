//
//  RosslerAttractorGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Rossler Attractor Fractal Generator
struct RosslerAttractorGenerator: PointFractalGenerator {
    func generate(with parameters: AttractorParameters) -> [CGPoint] {
        return generatePoints(with: parameters)
    }

    func generatePoints(with parameters: AttractorParameters) -> [CGPoint] {
        let width = parameters.size.width
        let height = parameters.size.height
        let scale = 30.0
        let offsetX = Double(width) / 2
        let offsetY = Double(height) / 2
        let a = 0.2
        let b = 0.2
        let c = 5.7
        var x = 0.1
        var y = 0.0
        var z = 0.0
        let dt = parameters.dt
        var points: [CGPoint] = []
        for _ in 0 ..< parameters.iterations {
            let dx = -y - z
            let dy = x + a * y
            let dz = b + z * (x - c)
            x += dx * dt
            y += dy * dt
            z += dz * dt
            let px = x * scale + offsetX
            let py = y * scale + offsetY
            if px >= 0 && px < Double(width) && py >= 0 && py < Double(height) {
                points.append(CGPoint(x: px, y: py))
            }
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
