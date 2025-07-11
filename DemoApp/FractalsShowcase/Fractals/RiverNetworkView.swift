//
//  RiverNetworkView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import Foundation
import SwiftUI

/**
 * Fractal River Network
 *
 * This view simulates the branching structure of river networks using recursive
 * branching patterns that mimic natural drainage systems and watersheds.
 *
 * Mathematical Foundation:
 * - Uses recursive branching with two tributaries per river segment
 * - Each tributary branches at ±45° angles with random variation
 * - Length and width decrease with each branching level
 * - The network flows downward, simulating gravity-driven drainage
 *
 * Properties:
 * - Fractal dimension typically between 1.5 and 2.0
 * - Self-similar branching at all scales
 * - Mimics natural river networks and drainage basins
 * - Demonstrates how simple rules create complex natural patterns
 */

struct RiverNetworkView: NSViewRepresentable {
    let iterations: Int // Recursion depth for branching

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateRiverNetwork(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateRiverNetwork(iterations: iterations)
    }

    func generateRiverNetwork(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let initialLength = Double(height) * 0.25

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background (land)
        context.setFillColor(NSColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0).cgColor) // Brownish
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Start at top center (source of river)
        let startX = Double(width) / 2
        let startY = Double(height) * 0.1

        // Draw the river network
        drawRiver(context: context,
                  x: startX,
                  y: startY,
                  length: initialLength,
                  angle: .pi / 2, // Downward flow
                  depth: iterations,
                  width: 8.0) // Initial river width

        image.unlockFocus()
        return image
    }

    private func drawRiver(context: CGContext, x: Double, y: Double, length: Double, angle: Double, depth: Int, width: Double) {
        if depth <= 0 || width < 1.0 {
            return
        }

        // Calculate end point
        let endX = x + cos(angle) * length
        let endY = y + sin(angle) * length

        // Set river color and width
        context.setStrokeColor(NSColor.blue.cgColor)
        context.setLineWidth(width)

        // Draw the river segment
        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: endX, y: endY))
        context.strokePath()

        // Parameters for tributaries
        let branchAngle = Double.pi / 4 // 45 degrees for tributaries
        let lengthShrink = 0.75 // Tributaries are 75% of parent length
        let widthShrink = 0.8 // Width reduces faster to mimic erosion

        // Random variation to simulate natural irregularity
        let angleVariation = Double.random(in: -0.1 ... 0.1)
        let leftAngle = angle - branchAngle + angleVariation
        let rightAngle = angle + branchAngle - angleVariation

        // Draw left tributary
        drawRiver(context: context,
                  x: endX,
                  y: endY,
                  length: length * lengthShrink,
                  angle: leftAngle,
                  depth: depth - 1,
                  width: width * widthShrink)

        // Draw right tributary
        drawRiver(context: context,
                  x: endX,
                  y: endY,
                  length: length * lengthShrink,
                  angle: rightAngle,
                  depth: depth - 1,
                  width: width * widthShrink)
    }
}
