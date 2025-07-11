//
//  RosslerAttractorView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Rössler Attractor Fractal
 *
 * The Rössler Attractor is a strange attractor arising from a system of three
 * coupled differential equations that produce a single spiral with chaotic behavior.
 * It's simpler than the Lorenz Attractor but still exhibits fractal structure.
 *
 * Mathematical Foundation:
 * - The Rössler system is defined by:
 *   dx/dt = -y - z
 *   dy/dt = x + a·y
 *   dz/dt = b + z·(x - c)
 * - Classic parameters: a = 0.2, b = 0.2, c = 5.7
 * - The system exhibits chaotic behavior with a single spiral attractor
 *
 * Fractal Properties:
 * - Fractal dimension ≈ 2.01
 * - Self-similar structure in the spiral's folding
 * - Simpler than Lorenz but still demonstrates deterministic chaos
 * - The trajectory stretches and folds chaotically around a single center
 */

struct RosslerAttractorView: NSViewRepresentable {
    let iterations: Int // Number of integration steps
    let dt: Double = 0.02 // Time step for numerical integration

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateRosslerAttractor(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateRosslerAttractor(iterations: iterations)
    }

    func generateRosslerAttractor(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let scale = 30.0 // Scaling factor for visualization
        let offsetX = Double(width) / 2
        let offsetY = Double(height) / 2

        // Rössler parameters
        let a = 0.2
        let b = 0.2
        let c = 5.7

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

        // Set attractor color
        context.setFillColor(NSColor.red.cgColor)

        // Generate the attractor trajectory
        for _ in 0 ..< iterations {
            // Rössler equations
            let dx = -y - z
            let dy = x + a * y
            let dz = b + z * (x - c)

            // Update state using Euler method
            x += dx * dt
            y += dy * dt
            z += dz * dt

            // Plot x vs y (shows the spiral clearly)
            let px = Int(x * scale + offsetX)
            let py = Int(y * scale + offsetY)

            if px >= 0 && px < width && py >= 0 && py < height {
                context.fill(CGRect(x: px, y: py, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }
}
