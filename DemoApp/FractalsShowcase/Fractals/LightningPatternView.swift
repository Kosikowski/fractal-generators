//
//  LightningPatternView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Fractal Lightning Pattern
 *
 * This view simulates the branching, self-similar structure of lightning using recursive
 * random branching, mimicking the natural fractal geometry of electrical discharges.
 *
 * Mathematical Foundation:
 * - Recursive branching with random angles and lengths
 * - Each branch splits at a random angle, with length and width decreasing at each level
 * - The process is repeated to a set recursion depth, creating a fractal pattern
 *
 * Properties:
 * - Fractal dimension typically between 1.2 and 1.7 (natural lightning)
 * - Self-similar at all scales
 * - Mimics the unpredictable, chaotic paths of real lightning
 */

struct LightningPatternView: NSViewRepresentable {
    let iterations: Int // Recursion depth for branching

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateLightningPattern(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateLightningPattern(iterations: iterations)
    }

    func generateLightningPattern(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let initialLength = Double(height) * 0.3

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background (night sky)
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Start at top center (cloud source)
        let startX = Double(width) / 2
        let startY = Double(height) * 0.1

        // Draw the lightning bolt
        drawLightning(context: context,
                      x: startX,
                      y: startY,
                      length: initialLength,
                      angle: .pi / 2, // Downward initial direction
                      depth: iterations,
                      width: 3.0) // Initial bolt width

        image.unlockFocus()
        return image
    }

    private func drawLightning(context: CGContext, x: Double, y: Double, length: Double, angle: Double, depth: Int, width: Double) {
        if depth <= 0 || length < 5.0 {
            return
        }

        // Calculate end point with random perturbation
        let perturbation = Double.random(in: -0.3 ... 0.3) // Chaotic deviation
        let adjustedAngle = angle + perturbation
        let endX = x + cos(adjustedAngle) * length
        let endY = y + sin(adjustedAngle) * length

        // Set lightning color and width (glowing effect)
        context.setStrokeColor(NSColor.white.cgColor)
        context.setLineWidth(width)
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 5.0, color: NSColor.cyan.cgColor)

        // Draw the main bolt segment
        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: endX, y: endY))
        context.strokePath()

        // Parameters for branching
        let branchChance = 0.7 // Probability of branching
        let branchAngle = Double.pi / 3 // 60 degrees for branches
        let lengthShrink = 0.6 // Branches are shorter
        let widthShrink = 0.7 // Branches are thinner

        // Randomly decide to branch
        if Double.random(in: 0 ... 1) < branchChance {
            let leftAngle = adjustedAngle - branchAngle + Double.random(in: -0.2 ... 0.2)
            drawLightning(context: context,
                          x: endX,
                          y: endY,
                          length: length * lengthShrink,
                          angle: leftAngle,
                          depth: depth - 1,
                          width: width * widthShrink)

            let rightAngle = adjustedAngle + branchAngle + Double.random(in: -0.2 ... 0.2)
            drawLightning(context: context,
                          x: endX,
                          y: endY,
                          length: length * lengthShrink,
                          angle: rightAngle,
                          depth: depth - 1,
                          width: width * widthShrink)
        } else {
            // Continue main path if no branch
            drawLightning(context: context,
                          x: endX,
                          y: endY,
                          length: length * lengthShrink,
                          angle: adjustedAngle,
                          depth: depth - 1,
                          width: width * widthShrink)
        }
    }
}
