//
//  LorenzAttractorView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import Foundation
import SwiftUI

/**
 * Lorenz Attractor Fractal
 *
 * The Lorenz Attractor is a strange attractor arising from a system of three coupled
 * differential equations that model atmospheric convection. It's one of the most famous
 * examples of chaos theory.
 *
 * Mathematical Foundation:
 * - The Lorenz system is defined by:
 *   dx/dt = σ(y - x)
 *   dy/dt = x(ρ - z) - y
 *   dz/dt = xy - βz
 * - Classic parameters: σ = 10, ρ = 28, β = 8/3
 * - The system exhibits chaotic behavior with sensitive dependence on initial conditions
 *
 * Fractal Properties:
 * - Fractal dimension ≈ 2.06
 * - Self-similar structure at all scales
 * - The attractor has a characteristic butterfly shape
 * - Demonstrates deterministic chaos
 */

struct LorenzAttractorView: NSViewRepresentable {
    let iterations: Int
    let dt: Double = 0.01 // Time step

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateLorenzAttractor(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateLorenzAttractor(iterations: iterations)
    }

    func generateLorenzAttractor(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let scale = 15.0
        let offsetX = Double(width) / 2
        let offsetY = Double(height) / 2

        // Lorenz parameters
        let sigma = 10.0
        let rho = 28.0
        let beta = 8.0 / 3.0

        // Initial conditions
        var x = 0.1
        var y = 0.0
        var z = 0.0

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set point color
        context.setFillColor(NSColor.blue.cgColor)

        // Generate points using Lorenz equations
        for _ in 0 ..< iterations {
            // Calculate derivatives
            let dx = sigma * (y - x)
            let dy = x * (rho - z) - y
            let dz = x * y - beta * z

            // Update positions
            x += dx * dt
            y += dy * dt
            z += dz * dt

            // Project to 2D (using x and z coordinates)
            let px = Int(x * scale + offsetX)
            let py = Int(z * scale + offsetY)

            // Draw point if within bounds
            if px >= 0 && px < width && py >= 0 && py < height {
                context.fill(CGRect(x: px, y: py, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }
}
