//
//  DragonCurveView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Dragon Curve Fractal
 *
 * The Dragon Curve is a space-filling fractal curve that was discovered by
 * NASA physicist John Heighway in 1966. It's created using an L-system
 * (Lindenmayer system) with string rewriting rules.
 *
 * Mathematical Foundation:
 * - Uses an L-system with alphabet: {F, +, -, X, Y}
 * - Production rules:
 *   X → X+YF+
 *   Y → -FX-Y
 *
 * Where:
 * - F: Draw forward
 * - +: Turn right 90°
 * - -: Turn left 90°
 * - X, Y: Variables that get replaced by the rules
 *
 * Algorithm:
 * 1. Start with axiom "FX"
 * 2. Apply production rules iteratively
 * 3. Interpret the resulting string as drawing instructions
 *
 * Fractal Properties:
 * - Fractal dimension = 2 (space-filling)
 * - Self-similar at all scales
 * - Eventually tiles the plane
 * - Each iteration roughly doubles the number of segments
 *
 * The curve folds back on itself in a complex pattern,
 * creating a dragon-like shape that becomes more detailed
 * with each iteration.
 */

struct DragonCurveView: NSViewRepresentable {
    let iterations: Int

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateDragonCurve(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateDragonCurve(iterations: iterations)
    }

    func generateDragonCurve(iterations: Int) -> NSImage {
        let size = 600
        let image = NSImage(size: CGSize(width: size, height: size))

        // Generate the L-system string
        var sequence = "FX"
        for _ in 0 ..< iterations {
            sequence = applyDragonRules(to: sequence)
        }

        // Drawing parameters
        let scale = Double(size) / pow(2, Double(iterations) / 2) * 0.5
        var x = Double(size) / 2
        var y = Double(size) / 2
        var angle = 0.0

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Set line color and width
        context.setStrokeColor(NSColor.red.cgColor)
        context.setLineWidth(1.0)

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
                angle += .pi / 2 // 90 degrees clockwise
            case "-":
                angle -= .pi / 2 // 90 degrees counterclockwise
            default:
                continue
            }
        }

        context.strokePath()
        image.unlockFocus()

        return image
    }

    // Apply L-system production rules
    private func applyDragonRules(to input: String) -> String {
        var result = ""
        for char in input {
            switch char {
            case "X":
                result += "X+YF+"
            case "Y":
                result += "-FX-Y"
            default:
                result.append(char)
            }
        }
        return result
    }
}
