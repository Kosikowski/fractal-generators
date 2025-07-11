//
//  LevyCCurveView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Lévy C Curve Fractal
 *
 * The Lévy C Curve is a self-similar fractal curve constructed by recursively replacing
 * each line segment with two segments joined at a 45° angle, forming a characteristic 'C' shape.
 *
 * Mathematical Foundation:
 * - At each iteration, every line segment is replaced by two segments at 45° angles
 * - The length of each new segment is scaled by \( \sqrt{2}/2 \)
 * - The process is repeated recursively, creating a jagged, self-similar curve
 *
 * Properties:
 * - Fractal dimension: \( \log 2 / \log(\sqrt{2}) = 2 \)
 * - The curve becomes increasingly space-filling with more iterations
 * - Exhibits self-similarity at all scales
 */

struct LevyCCurveView: NSViewRepresentable {
    let iterations: Int // Recursion depth

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateLevyCCurve(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateLevyCCurve(iterations: iterations)
    }

    func generateLevyCCurve(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        // Larger initial length, less aggressive scaling
        let initialLength = Double(width) * 0.7 * pow(0.8, Double(iterations))

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set curve color and increase line width
        context.setStrokeColor(NSColor.yellow.cgColor) // Brighter color
        context.setLineWidth(2.0) // Thicker line

        // Start at center, horizontal initial direction
        let startX = Double(width) / 2 - initialLength / 2
        let startY = Double(height) / 2

        // Draw the Lévy C Curve
        context.beginPath()
        drawLevyC(context: context,
                  x: startX,
                  y: startY,
                  length: initialLength,
                  angle: 0, // Rightward initial direction
                  depth: iterations)
        context.strokePath()

        image.unlockFocus()
        return image
    }

    private func drawLevyC(context: CGContext, x: Double, y: Double, length: Double, angle: Double, depth: Int) {
        if depth <= 0 {
            // Draw straight line segment
            let endX = x + cos(angle) * length
            let endY = y + sin(angle) * length
            context.move(to: CGPoint(x: x, y: y))
            context.addLine(to: CGPoint(x: endX, y: endY))
            return
        }

        // Scale factor for new segments (√2/2 due to 45° angle)
        let newLength = length * (sqrt(2) / 2)

        // First segment: turn +45°
        let angle1 = angle + .pi / 4 // 45° counterclockwise
        let midX = x + cos(angle1) * newLength
        let midY = y + sin(angle1) * newLength

        // Recursively draw first segment
        drawLevyC(context: context,
                  x: x,
                  y: y,
                  length: newLength,
                  angle: angle1,
                  depth: depth - 1)

        // Second segment: turn -90° from first segment’s end
        let angle2 = angle1 - .pi / 2 // 90° clockwise from first segment
        drawLevyC(context: context,
                  x: midX,
                  y: midY,
                  length: newLength,
                  angle: angle2,
                  depth: depth - 1)
    }
}
