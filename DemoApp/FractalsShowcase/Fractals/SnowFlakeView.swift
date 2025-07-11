//
//  SnowFlakeView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Koch Snowflake Fractal
 *
 * The Koch Snowflake is a fractal curve created by applying the Koch curve
 * construction to each side of an equilateral triangle. It's one of the earliest
 * fractals discovered and demonstrates how simple rules create complex patterns.
 *
 * Mathematical Foundation:
 * - Start with an equilateral triangle
 * - Replace each side with a Koch curve
 * - The Koch curve rule: F → F+F--F+F
 * - Each iteration adds more detail to the boundary
 * - The process continues recursively to the desired depth
 *
 * Properties:
 * - Fractal dimension = log(4)/log(3) ≈ 1.262
 * - Self-similar at all scales
 * - Has finite area but infinite perimeter
 * - Exhibits perfect six-fold symmetry
 */

struct SnowflakeView: NSViewRepresentable {
    let iterations: Int

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateSnowflake(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateSnowflake(iterations: iterations)
    }

    func generateSnowflake(iterations: Int) -> NSImage {
        let size = 600
        let image = NSImage(size: CGSize(width: size, height: size))

        // Calculate scale based on iterations
        let scaleFactor = pow(1.0 / 3.0, Double(iterations))
        let sideLength = Double(size) * 0.5 * scaleFactor

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Set line color and width
        context.setStrokeColor(NSColor.blue.cgColor)
        context.setLineWidth(1.0)

        // Generate Koch curve string
        var sequence = "F--F--F" // Initial equilateral triangle
        for _ in 0 ..< iterations {
            sequence = applyKochRules(to: sequence)
        }

        // Drawing parameters
        let centerX = Double(size) / 2
        let centerY = Double(size) / 2
        var x = centerX + sideLength * cos(.pi / 2) // Start at top
        var y = centerY - sideLength * sin(.pi / 2)
        var angle = 0.0

        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))

        // Draw the snowflake
        for char in sequence {
            switch char {
            case "F":
                let newX = x + cos(angle) * sideLength
                let newY = y + sin(angle) * sideLength
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

        context.closePath()
        context.strokePath()
        image.unlockFocus()

        return image
    }

    // Apply Koch curve L-system rules
    private func applyKochRules(to input: String) -> String {
        var result = ""
        for char in input {
            switch char {
            case "F":
                result += "F+F--F+F"
            default:
                result.append(char)
            }
        }
        return result
    }
}
