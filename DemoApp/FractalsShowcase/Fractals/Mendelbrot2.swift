//
//  Mendelbrot2.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import ComplexModule
import Foundation
import SwiftUI

/**
 * Mandelbrot Set Implementation
 *
 * This is an alternative implementation of the Mandelbrot set using NSViewRepresentable.
 * The Mandelbrot set is the set of complex numbers c for which the function
 * f(z) = z² + c does not diverge when iterated from z = 0.
 *
 * Mathematical Foundation:
 * - Uses the iteration: z[n+1] = z[n]² + c
 * - z[0] = 0, c is the complex coordinate being tested
 * - Points where |z| > 2 escape to infinity
 * - Points that remain bounded form the Mandelbrot set
 * - The boundary exhibits infinite detail and self-similarity
 *
 * Properties:
 * - Fractal dimension of the boundary ≈ 2
 * - Self-similar at all scales
 * - Shows intricate detail in the boundary regions
 * - Demonstrates the beauty of complex dynamics
 */

struct MandelbrotSetView: NSViewRepresentable {
    let iterations: Int
    let zoom: CGFloat = 1.5

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateMandelbrotSet(size: CGSize(width: 600, height: 600), iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateMandelbrotSet(size: CGSize(width: 600, height: 600), iterations: iterations)
    }

    func generateMandelbrotSet(size: CGSize, iterations: Int) -> NSImage {
        let width = Int(size.width)
        let height = Int(size.height)
        let image = NSImage(size: size)

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        for x in 0 ..< width {
            for y in 0 ..< height {
                let cx = (Double(x) - Double(size.width) / 2) / (Double(size.width) / Double(zoom))
                let cy = (Double(y) - Double(size.height) / 2) / (Double(size.height) / Double(zoom))
                let color = mandelbrotColor(cx: cx, cy: cy, iterations: iterations)
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }

    func mandelbrotColor(cx: Double, cy: Double, iterations: Int) -> NSColor {
        var z = Complex(0.0, 0.0)
        let c = Complex(cx, cy)
        var iter = 0
        while iter < iterations, z.lengthSquared < 4.0 {
            z = z * z + c
            iter += 1
        }
        let colorFactor = CGFloat(iter) / CGFloat(iterations)
        return NSColor(hue: colorFactor, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
}
