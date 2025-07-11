//
//  ChuaCircuitGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Chua's Circuit Strange Attractor Generator
 *
 * Chua's Circuit is a real electronic circuit that exhibits chaotic behavior,
 * producing a double-scroll strange attractor. It's one of the simplest
 * electronic circuits capable of chaos.
 *
 * Mathematical Foundation:
 * The circuit is described by three coupled differential equations:
 *
 * dx/dt = α(y - x - g(x))
 * dy/dt = x - y + z
 * dz/dt = -βy
 *
 * Where g(x) is a piecewise-linear function representing the nonlinear Chua diode:
 * g(x) = m₁x + 0.5(m₀ - m₁)(|x + 1| - |x - 1|)
 *
 * Parameters:
 * - α = 15.6 (controls the dynamics)
 * - β = 28.0 (controls the coupling)
 * - m₀ = -1.143, m₁ = -0.714 (diode characteristics)
 *
 * The double-scroll attractor emerges from two unstable equilibrium points,
 * creating a fractal structure with self-similarity at all scales.
 * The fractal dimension of this attractor is approximately 2.06.
 */

struct ChuaCircuitParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let dt: Double

    init(iterations: Int = 10000, size: CGSize = CGSize(width: 600, height: 600), dt: Double = 0.02) {
        self.iterations = iterations
        self.size = size
        self.dt = dt
    }
}

struct ChuaCircuitGenerator: PointFractalGenerator {
    func generate(with parameters: ChuaCircuitParameters) -> [CGPoint] {
        return generatePoints(with: parameters)
    }

    func generatePoints(with parameters: ChuaCircuitParameters) -> [CGPoint] {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let scale = 40.0 // Scaling factor for visualization
        let offsetX = Double(width) / 2
        let offsetY = Double(height) / 2

        // Chua's Circuit parameters
        let alpha = 15.6
        let beta = 28.0
        let m0 = -1.143
        let m1 = -0.714

        // Initial conditions
        var x = 0.7
        var y = 0.0
        var z = 0.0

        var points: [CGPoint] = []

        // Nonlinear function g(x) for Chua's diode
        func g(_ x: Double) -> Double {
            return m1 * x + 0.5 * (m0 - m1) * (abs(x + 1) - abs(x - 1))
        }

        // Generate the attractor trajectory using Euler integration
        for _ in 0 ..< parameters.iterations {
            // Chua's equations
            let dx = alpha * (y - x - g(x))
            let dy = x - y + z
            let dz = -beta * y

            // Update state using Euler method
            x += dx * parameters.dt
            y += dy * parameters.dt
            z += dz * parameters.dt

            // Plot x vs z (double-scroll is most visible here)
            let px = Int(x * scale + offsetX)
            let py = Int(z * scale + offsetY)

            if px >= 0 && px < width && py >= 0 && py < height {
                points.append(CGPoint(x: px, y: py))
            }
        }

        return points
    }

    func generateAsync(with parameters: ChuaCircuitParameters,
                       progress: @escaping (Double) -> Void,
                       completion: @escaping ([CGPoint]) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let points = self.generatePoints(with: parameters)
            DispatchQueue.main.async {
                progress(1.0)
                completion(points)
            }
        }
    }
}
