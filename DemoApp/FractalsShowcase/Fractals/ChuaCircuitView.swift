//
//  ChuaCircuitView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Chua's Circuit Strange Attractor
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

struct ChuaCircuitView: NSViewRepresentable {
    let iterations: Int // Number of integration steps
    let dt: Double = 0.02 // Time step for numerical integration

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateChuaCircuit(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateChuaCircuit(iterations: iterations)
    }

    func generateChuaCircuit(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
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

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set attractor color
        context.setFillColor(NSColor.yellow.cgColor)

        // Nonlinear function g(x) for Chua's diode
        func g(_ x: Double) -> Double {
            return m1 * x + 0.5 * (m0 - m1) * (abs(x + 1) - abs(x - 1))
        }

        // Generate the attractor trajectory using Euler integration
        for _ in 0 ..< iterations {
            // Chua's equations
            let dx = alpha * (y - x - g(x))
            let dy = x - y + z
            let dz = -beta * y

            // Update state using Euler method
            x += dx * dt
            y += dy * dt
            z += dz * dt

            // Plot x vs z (double-scroll is most visible here)
            let px = Int(x * scale + offsetX)
            let py = Int(z * scale + offsetY)

            if px >= 0 && px < width && py >= 0 && py < height {
                context.fill(CGRect(x: px, y: py, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }
}
