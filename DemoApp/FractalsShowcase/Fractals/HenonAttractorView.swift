//
//  HenonAttractorView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Hénon Attractor Fractal
 *
 * The Hénon Attractor is a strange attractor arising from the Hénon map,
 * a discrete-time dynamical system that exhibits chaotic behavior and fractal structure.
 *
 * Mathematical Foundation:
 * - The Hénon map is defined by:
 *   x[n+1] = 1 - a * x[n]^2 + y[n]
 *   y[n+1] = b * x[n]
 * - Classic parameters: a = 1.4, b = 0.3
 * - The system is iterated from an initial point, and after a warm-up period,
 *   the points settle onto a fractal attractor in the (x, y) plane.
 *
 * Fractal Properties:
 * - The attractor has a fractal dimension ≈ 1.261
 * - Self-similar, with a characteristic curved, layered pattern
 * - Demonstrates sensitive dependence on initial conditions (chaos)
 * - Unlike continuous attractors (e.g., Lorenz), this is a discrete map
 *
 * The Hénon Attractor is a classic example of a simple system producing
 * complex, fractal, and chaotic behavior.
 */

struct HenonAttractorView: NSViewRepresentable {
    let iterations: Int

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateHenonAttractor(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateHenonAttractor(iterations: iterations)
    }

    func generateHenonAttractor(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let scale = 200.0
        let offsetX = Double(width) / 2
        let offsetY = Double(height) / 2

        // Hénon map parameters
        let a = 1.4
        let b = 0.3

        // Initial conditions
        var x = 0.0
        var y = 0.0

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set point color
        context.setFillColor(NSColor.purple.cgColor)

        // Warm-up iterations to reach the attractor
        for _ in 0 ..< 100 {
            let xNext = 1 - a * x * x + y
            y = b * x
            x = xNext
        }

        // Generate and plot points
        for _ in 0 ..< iterations {
            let xNext = 1 - a * x * x + y
            let yNext = b * x

            let px = Int(x * scale + offsetX)
            let py = Int(y * scale + offsetY)

            // Draw point if within bounds
            if px >= 0 && px < width && py >= 0 && py < height {
                context.fill(CGRect(x: px, y: py, width: 1, height: 1))
            }

            x = xNext
            y = yNext
        }

        image.unlockFocus()
        return image
    }
}
