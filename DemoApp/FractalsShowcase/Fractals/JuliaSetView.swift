//
//  JuliaSetView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import ComplexModule
import SwiftUI

/**
 * Julia Set Fractal
 *
 * The Julia set is a fractal related to the Mandelbrot set. For a given complex
 * number c, the Julia set is the set of complex numbers z for which the function
 * f(z) = z² + c does not diverge when iterated from z.
 *
 * Mathematical Foundation:
 * - Uses the iteration: z[n+1] = z[n]² + c
 * - c is a fixed complex parameter
 * - z[0] varies over the complex plane
 * - Points where |z| > 2 escape to infinity
 * - Points that remain bounded form the Julia set
 *
 * Properties:
 * - Fractal dimension varies with the parameter c
 * - Self-similar at all scales
 * - Connected when c is in the Mandelbrot set
 * - Disconnected (dust) when c is outside the Mandelbrot set
 */

struct JuliaSetView: NSViewRepresentable {
    let iterations: Int
    let zoom: CGFloat = 1.5
    let c: Complex<Double> = Complex(-0.7, 0.27015) // Example constant for Julia set

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateJuliaSet(size: CGSize(width: 600, height: 600), iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateJuliaSet(size: CGSize(width: 600, height: 600), iterations: iterations)
    }

    func generateJuliaSet(size: CGSize, iterations: Int) -> NSImage {
        let width = Int(size.width)
        let height = Int(size.height)
        let image = NSImage(size: size)

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        for x in 0 ..< width {
            for y in 0 ..< height {
                let zx = (Double(x) - Double(size.width) / 2) / (Double(size.width) / Double(zoom))
                let zy = (Double(y) - Double(size.height) / 2) / (Double(size.height) / Double(zoom))
                let color = juliaColor(zx: zx, zy: zy, iterations: iterations)
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }

    func juliaColor(zx: Double, zy: Double, iterations: Int) -> NSColor {
        var z = Complex(zx, zy)
        var iter = 0
        while iter < iterations, z.lengthSquared < 4.0 {
            z = z * z + c
            iter += 1
        }
        let colorFactor = CGFloat(iter) / CGFloat(iterations)
        return NSColor(hue: colorFactor, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
}
