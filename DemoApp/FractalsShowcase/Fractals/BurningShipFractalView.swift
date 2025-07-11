//
//  BurningShipFractalView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import ComplexModule
import SwiftUI

/**
 * Burning Ship Fractal
 *
 * The Burning Ship fractal is a variation of the Mandelbrot set that uses
 * the absolute value of the real and imaginary parts in the iteration formula.
 * It creates a distinctive "ship" shape with intricate detail.
 *
 * Mathematical Foundation:
 * - Uses the iteration: z = (|Re(z)| + i|Im(z)|)² + c
 * - Takes absolute values of real and imaginary parts before squaring
 * - Creates a fractal with a distinctive ship-like main body
 * - Shows complex boundary behavior and self-similar structures
 *
 * Properties:
 * - Self-similar at all scales
 * - Has a characteristic "burning ship" shape
 * - Demonstrates how small changes in iteration rules create vastly different fractals
 * - Shows the sensitivity of fractal boundaries to mathematical variations
 */

struct BurningShipFractalView: NSViewRepresentable {
    let iterations: Int
    let zoom: CGFloat = 1.5

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateBurningShipFractal(size: CGSize(width: 600, height: 600), iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateBurningShipFractal(size: CGSize(width: 600, height: 600), iterations: iterations)
    }

    func generateBurningShipFractal(size: CGSize, iterations: Int) -> NSImage {
        let width = Int(size.width)
        let height = Int(size.height)
        let image = NSImage(size: size)

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        for x in 0 ..< width {
            for y in 0 ..< height {
                let cx = (Double(x) - Double(size.width) / 2) / (Double(size.width) / Double(zoom))
                let cy = (Double(y) - Double(size.height) / 2) / (Double(size.height) / Double(zoom))
                let color = burningShipColor(cx: cx, cy: cy, iterations: iterations)
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }

    func burningShipColor(cx: Double, cy: Double, iterations: Int) -> NSColor {
        var z = Complex(0.0, 0.0)
        let c = Complex(cx, cy)
        var iter = 0
        while iter < iterations, z.lengthSquared < 4.0 {
            z = Complex(abs(z.real), abs(z.imaginary)) * Complex(
                abs(z.real),
                abs(z.imaginary)
            ) + c
            iter += 1
        }
        let colorFactor = CGFloat(iter) / CGFloat(iterations)
        return NSColor(hue: colorFactor, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
}
