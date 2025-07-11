//
//  LevyFlightView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Lévy Flight Fractal Path
 *
 * Lévy flights are random walks where the step lengths follow a heavy-tailed power-law distribution.
 * This results in a path with clusters of short steps and occasional long jumps, producing fractal patterns.
 *
 * Mathematical Foundation:
 * - Step length distribution: \( P(l) \propto l^{-\alpha} \), with 1 < α < 3
 * - Each step: random direction, power-law-distributed length
 * - The resulting path is self-similar and fractal
 *
 * Properties:
 * - Fractal dimension depends on α (for α=1.5, D ≈ 2)
 * - Models natural phenomena like animal foraging, diffusion, and turbulence
 * - Characterized by clusters and rare, long jumps
 */

struct LevyFlightView: NSViewRepresentable {
    let steps: Int // Number of steps in the walk

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateLevyFlight(steps: steps)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateLevyFlight(steps: steps)
    }

    func generateLevyFlight(steps: Int) -> NSImage {
        let width = 600
        let height = 600
        let image = NSImage(size: CGSize(width: width, height: height))

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set path color and width
        context.setStrokeColor(NSColor.red.cgColor)
        context.setLineWidth(1.0)

        // Start at center
        var x = Double(width) / 2
        var y = Double(height) / 2

        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))

        // Parameters for Lévy distribution (power-law)
        let alpha = 1.5 // Lévy exponent (1 < alpha < 2 for stable flights)
        let minStep = 1.0 // Minimum step length
        let maxStep = Double(width) * 0.3 // Maximum step length

        // Generate the Lévy Flight path
        for _ in 0 ..< steps {
            // Random direction
            let angle = Double.random(in: 0 ..< 2 * .pi)

            // Lévy step length (approximated via power-law)
            let u = Double.random(in: 0 ... 1)
            let stepLength = minStep * pow(1.0 - u, -1.0 / alpha)
            let clampedStep = min(maxStep, max(minStep, stepLength))

            // Calculate new position
            let newX = x + cos(angle) * clampedStep
            let newY = y + sin(angle) * clampedStep

            // Draw line if within bounds
            if newX >= 0 && newX < Double(width) && newY >= 0 && newY < Double(height) {
                context.addLine(to: CGPoint(x: newX, y: newY))
                x = newX
                y = newY
            } else {
                // Reset to last valid position if out of bounds
                context.move(to: CGPoint(x: x, y: y))
            }
        }

        context.strokePath()
        image.unlockFocus()
        return image
    }
}
