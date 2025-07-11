//
//  LorenzAttractorGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Lorenz Attractor Fractal Generator
///
/// The Lorenz Attractor is a strange attractor arising from a system of three coupled
/// differential equations that model atmospheric convection. It's one of the most famous
/// examples of chaos theory.
///
/// Mathematical Foundation:
/// - The Lorenz system is defined by:
///   dx/dt = σ(y - x)
///   dy/dt = x(ρ - z) - y
///   dz/dt = xy - βz
/// - Classic parameters: σ = 10, ρ = 28, β = 8/3
/// - The system exhibits chaotic behavior with sensitive dependence on initial conditions
struct LorenzAttractorGenerator: PointFractalGenerator {
    func generate(with parameters: AttractorParameters) -> [CGPoint] {
        return generatePoints(with: parameters)
    }

    func generatePoints(with parameters: AttractorParameters) -> [CGPoint] {
        var points: [CGPoint] = []

        let sigma = 10.0
        let rho = 28.0
        let beta = 8.0 / 3.0

        var x = parameters.initialConditions[0]
        var y = parameters.initialConditions[1]
        var z = parameters.initialConditions[2]

        let offsetX = parameters.size.width / 2
        let offsetY = parameters.size.height / 2

        for _ in 0 ..< parameters.iterations {
            let dx = sigma * (y - x)
            let dy = x * (rho - z) - y
            let dz = x * y - beta * z

            x += dx * parameters.dt
            y += dy * parameters.dt
            z += dz * parameters.dt

            let px = x * parameters.scale + offsetX
            let py = z * parameters.scale + offsetY

            if px >= 0 && px < parameters.size.width && py >= 0 && py < parameters.size.height {
                points.append(CGPoint(x: px, y: py))
            }
        }

        return points
    }

    func generateAsync(with parameters: AttractorParameters,
                       progress _: @escaping (Double) -> Void,
                       completion: @escaping ([CGPoint]) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let points = self.generatePoints(with: parameters)
            DispatchQueue.main.async {
                completion(points)
            }
        }
    }
}
