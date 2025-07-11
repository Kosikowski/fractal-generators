//
//  LogisticMapView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Logistic Map Bifurcation Diagram
 *
 * The Logistic Map is a classic example of chaos theory, defined by the equation:
 * x[n+1] = r * x[n] * (1 - x[n])
 * where r is a parameter and x[n] is the population at time n.
 *
 * Mathematical Foundation:
 * - For r < 3: converges to a fixed point
 * - For 3 ≤ r < 3.57: period-doubling bifurcations (2, 4, 8, ... cycles)
 * - For r > 3.57: chaotic behavior with periodic windows
 * - The bifurcation diagram shows stable values of x for each r
 *
 * Fractal Properties:
 * - Self-similar structure in chaotic regions
 * - Fractal dimension ≈ 0.538 in chaotic regime
 * - Period-doubling cascade creates fractal patterns
 */

struct LogisticMapView: NSViewRepresentable {
    let iterations: Int // Number of iterations per r value to reach stability
    let rMin: Double = 2.5 // Minimum r value
    let rMax: Double = 4.0 // Maximum r value

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateLogisticMap()
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateLogisticMap()
    }

    func generateLogisticMap() -> NSImage {
        let width = 600
        let height = 600
        let image = NSImage(size: CGSize(width: width, height: height))

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set point color
        context.setFillColor(NSColor.white.cgColor)

        // Parameters
        let xInitial = 0.5 // Initial x value
        let transient = iterations / 2 // Skip initial iterations to avoid transients

        // Iterate over r values
        for rPixel in 0 ..< width {
            let r = rMin + (rMax - rMin) * Double(rPixel) / Double(width)
            var x = xInitial

            // Run iterations to reach stable behavior
            var values = Set<Double>()
            for i in 0 ..< iterations {
                x = r * x * (1 - x)
                if i >= transient {
                    // Record stable values
                    let scaledX = x * Double(height)
                    if scaledX >= 0 && scaledX < Double(height) {
                        values.insert(scaledX)
                    }
                }
            }

            // Plot stable points for this r
            for xValue in values {
                context.fill(CGRect(x: Double(rPixel), y: Double(height) - xValue, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }
}
