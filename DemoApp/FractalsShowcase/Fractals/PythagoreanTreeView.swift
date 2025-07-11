//
//  PythagoreanTreeView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Pythagorean Tree Fractal
 *
 * The Pythagorean Tree is a fractal tree constructed from squares, where each
 * square has two smaller squares attached to its top edge, forming a tree-like
 * structure that demonstrates the Pythagorean theorem.
 *
 * Mathematical Foundation:
 * - Each square has two child squares attached to its top edge
 * - The child squares are rotated by ±θ from the vertical
 * - Child squares are scaled by a factor s (typically √2/2 ≈ 0.707)
 * - The tree grows upward, with each level smaller than the previous
 *
 * Properties:
 * - Fractal dimension depends on the scaling factor and angle
 * - Self-similar structure at all scales
 * - Demonstrates geometric relationships from the Pythagorean theorem
 * - Creates a natural tree-like branching pattern
 */

struct PythagoreanTreeView: NSViewRepresentable {
    let iterations: Int
    let angle: Double // Angle of branching (radians)
    let scale: Double // Scaling factor for child squares

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generatePythagoreanTree(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generatePythagoreanTree(iterations: iterations)
    }

    func generatePythagoreanTree(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let initialSize = Double(height) * 0.2

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set square color
        context.setFillColor(NSColor.green.cgColor)
        context.setStrokeColor(NSColor.green.cgColor)
        context.setLineWidth(1.0)

        // Start at bottom center
        let startX = Double(width) / 2 - initialSize / 2
        let startY = Double(height) - initialSize

        // Draw the tree
        drawSquare(context: context,
                   x: startX,
                   y: startY,
                   size: initialSize,
                   angle: 0,
                   depth: iterations)

        image.unlockFocus()
        return image
    }

    private func drawSquare(context: CGContext, x: Double, y: Double, size: Double, angle: Double, depth: Int) {
        if depth <= 0 {
            return
        }

        // Define square vertices relative to bottom-left corner
        let points = [
            CGPoint(x: x, y: y), // Bottom-left
            CGPoint(x: x + size, y: y), // Bottom-right
            CGPoint(x: x + size, y: y + size), // Top-right
            CGPoint(x: x, y: y + size), // Top-left
        ]

        // Rotate points around bottom-left corner
        var rotatedPoints = [CGPoint]()
        for point in points {
            let dx = point.x - x
            let dy = point.y - y
            let newX = x + dx * cos(angle) - dy * sin(angle)
            let newY = y + dx * sin(angle) + dy * cos(angle)
            rotatedPoints.append(CGPoint(x: newX, y: newY))
        }

        // Draw the square
        context.beginPath()
        context.move(to: rotatedPoints[0])
        for i in 1 ..< 4 {
            context.addLine(to: rotatedPoints[i])
        }
        context.closePath()
        context.fillPath()

        // Calculate position for child squares (top edge becomes new base)
        let topLeft = rotatedPoints[3]
        let topRight = rotatedPoints[2]
        let newSize = size * scale

        // Left child square
        let leftAngle = angle + .pi / 2 - self.angle
        drawSquare(context: context,
                   x: topLeft.x,
                   y: topLeft.y,
                   size: newSize,
                   angle: leftAngle,
                   depth: depth - 1)

        // Right child square
        let rightAngle = angle + .pi / 2 + self.angle
        let rightBaseX = topRight.x - newSize * cos(rightAngle)
        let rightBaseY = topRight.y - newSize * sin(rightAngle)
        drawSquare(context: context,
                   x: rightBaseX,
                   y: rightBaseY,
                   size: newSize,
                   angle: rightAngle,
                   depth: depth - 1)
    }
}
