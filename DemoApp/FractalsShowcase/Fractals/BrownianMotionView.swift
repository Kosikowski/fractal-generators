//
//  BrownianMotionView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Brownian Motion Fractal
 *
 * Brownian motion is a random walk process that creates a fractal path.
 * Each step is taken in a random direction with a fixed step size,
 * creating a continuous but nowhere differentiable curve.
 *
 * Mathematical Foundation:
 * - Each step is taken in a random direction (uniform distribution)
 * - Step size is constant
 * - The path is continuous but nowhere differentiable
 * - The fractal dimension of a Brownian path is 2
 * - Shows how random processes can create fractal structures
 *
 * Properties:
 * - Fractal dimension = 2
 * - Self-similar at all scales
 * - Demonstrates the connection between randomness and fractals
 * - Shows how simple random rules create complex patterns
 */

struct BrownianMotionView: NSViewRepresentable {
    let steps: Int
    let stepSize: CGFloat = 5.0

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateBrownianMotion(size: CGSize(width: 600, height: 600), steps: steps)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateBrownianMotion(size: CGSize(width: 600, height: 600), steps: steps)
    }

    func generateBrownianMotion(size: CGSize, steps: Int) -> NSImage {
        let image = NSImage(size: size)

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext
        context.setStrokeColor(NSColor.blue.cgColor)
        context.setLineWidth(1.0)

        var x = size.width / 2
        var y = size.height / 2

        context.move(to: CGPoint(x: x, y: y))

        for _ in 0 ..< steps {
            let angle = Double.random(in: 0 ..< 2 * .pi)
            x += stepSize * CGFloat(cos(angle))
            y += stepSize * CGFloat(sin(angle))
            context.addLine(to: CGPoint(x: x, y: y))
        }

        context.strokePath()
        image.unlockFocus()
        return image
    }
}
