//
//  SierpinskiArrowheadView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Sierpinski Arrowhead Curve Fractal
 *
 * The Sierpinski Arrowhead Curve is a space-filling curve that approximates
 * the Sierpinski Triangle. It's created using an L-system with specific
 * production rules that generate a continuous path outlining the triangle.
 *
 * Mathematical Foundation:
 * - Uses an L-system with alphabet: {F, +, -, X, Y}
 * - Production rules:
 *   X → YF+XF+Y
 *   Y → XF-YF-X
 * - F: Draw forward, +: Turn right 60°, -: Turn left 60°
 * - The curve converges to the Sierpinski Triangle as iterations increase
 *
 * Properties:
 * - Fractal dimension = log(3)/log(2) ≈ 1.585
 * - Self-similar at all scales
 * - Creates a continuous, unbroken path
 * - Unlike the point-based Sierpinski Triangle, this is a single curve
 */

struct SierpinskiArrowheadView: NSViewRepresentable {
    let iterations: Int // Recursion depth

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateSierpinskiArrowhead(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateSierpinskiArrowhead(iterations: iterations)
    }

    func generateSierpinskiArrowhead(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let scale = Double(width) * 0.5 * pow(0.5, Double(iterations)) // Adjusted scaling

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set curve color and width
        context.setStrokeColor(NSColor.green.cgColor)
        context.setLineWidth(1.5)

        // Generate the L-system string
        var sequence = "YF" // Start with YF (odd iterations use XF, but we adjust starting point)
        for _ in 0 ..< iterations {
            sequence = applyArrowheadRules(to: sequence)
        }

        // Drawing parameters
        let startX = Double(width) / 4 // Shift left to fit triangle
        let startY = Double(height) * 0.75 // Start near bottom
        var x = startX
        var y = startY
        var angle = 0.0 // Initial direction upward

        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))

        // Interpret the L-system string
        for char in sequence {
            switch char {
            case "F":
                let newX = x + cos(angle) * scale
                let newY = y + sin(angle) * scale
                context.addLine(to: CGPoint(x: newX, y: newY))
                x = newX
                y = newY
            case "+":
                angle += .pi / 3 // 60 degrees clockwise
            case "-":
                angle -= .pi / 3 // 60 degrees counterclockwise
            default:
                continue
            }
        }

        context.strokePath()
        image.unlockFocus()
        return image
    }

    // Apply L-system production rules for Sierpinski Arrowhead
    private func applyArrowheadRules(to input: String) -> String {
        var result = ""
        for char in input {
            switch char {
            case "X":
                result += "YF+XF+Y"
            case "Y":
                result += "XF-YF-X"
            case "F":
                result += "F"
            case "+":
                result += "+"
            case "-":
                result += "-"
            default:
                continue
            }
        }
        return result
    }
}
