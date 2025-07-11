//
//  BarnsleyFernView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Barnsley Fern Fractal
 *
 * The Barnsley Fern is a fractal created using an iterated function system (IFS).
 * It mimics the structure of a fern using four affine transformations applied
 * with different probabilities.
 *
 * Mathematical Foundation:
 * - Uses four affine transformations with probabilities:
 *   - Stem: 1% probability
 *   - Successively smaller leaflets: 85%, 7%, 7% probabilities
 * - Each transformation has the form: x' = ax + by + e, y' = cx + dy + f
 * - The transformations create the fern's stem, leaves, and branching structure
 * - The process is stochastic, creating natural-looking variation
 *
 * Properties:
 * - Self-similar at all scales
 * - Mimics natural fern growth patterns
 * - Demonstrates how simple mathematical rules create complex natural forms
 * - Shows the power of iterated function systems
 */

struct BarnsleyFernView: NSViewRepresentable {
    let iterations: Int

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateBarnsleyFern(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateBarnsleyFern(iterations: iterations)
    }

    func generateBarnsleyFern(iterations: Int) -> NSImage {
        let width = 500
        let height = 600
        let scale = 60.0
        let offsetX = width / 2
        let offsetY = 50

        var x: Double = 0
        var y: Double = 0

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        context.setFillColor(NSColor.green.cgColor)

        for _ in 0 ..< iterations {
            let r = Double.random(in: 0 ... 1)
            var nextX = 0.0
            var nextY = 0.0

            if r < 0.01 {
                nextX = 0
                nextY = 0.16 * y
            } else if r < 0.86 {
                nextX = 0.85 * x + 0.04 * y
                nextY = -0.04 * x + 0.85 * y + 1.6
            } else if r < 0.93 {
                nextX = 0.2 * x - 0.26 * y
                nextY = 0.23 * x + 0.22 * y + 1.6
            } else {
                nextX = -0.15 * x + 0.28 * y
                nextY = 0.26 * x + 0.24 * y + 0.44
            }

            x = nextX
            y = nextY

            let px = Int(x * scale) + offsetX
            let py = Int(height - Int(y * scale) - offsetY)
            context.fill(CGRect(x: px, y: py, width: 1, height: 1))
        }

        image.unlockFocus()
        return image
    }
}
