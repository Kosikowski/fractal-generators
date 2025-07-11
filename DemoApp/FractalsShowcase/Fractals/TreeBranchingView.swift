//
//  TreeBranchingView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Fractal Tree Branching
 *
 * This view creates a fractal tree using recursive branching patterns that
 * mimic natural tree growth. Each branch splits into two smaller branches
 * at a specified angle, creating a self-similar structure.
 *
 * Mathematical Foundation:
 * - Each branch splits into two child branches
 * - Child branches are rotated by ±θ from the parent direction
 * - Branch length decreases by a scaling factor at each level
 * - The process continues recursively until the desired depth
 * - Line width decreases to simulate natural tapering
 *
 * Properties:
 * - Self-similar structure at all scales
 * - Mimics natural tree growth patterns
 * - Demonstrates how simple rules create complex natural forms
 * - Shows hierarchical branching typical of biological systems
 */

struct TreeBranchingView: NSViewRepresentable {
    let iterations: Int
    let branchAngle: Double = .pi / 6 // 30 degrees
    let lengthShrink: Double = 0.7 // 70% length reduction per branch

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateTree(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateTree(iterations: iterations)
    }

    func generateTree(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let initialLength = Double(height) * 0.3

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set branch color and initial width
        context.setStrokeColor(NSColor.brown.cgColor)

        // Start at bottom center
        let startX = Double(width) / 2
        let startY = Double(height)

        context.beginPath()
        drawBranch(context: context,
                   x: startX,
                   y: startY,
                   length: initialLength,
                   angle: -.pi / 2, // Straight up
                   depth: iterations,
                   width: 3.0)

        context.strokePath()
        image.unlockFocus()
        return image
    }

    private func drawBranch(context: CGContext, x: Double, y: Double, length: Double, angle: Double, depth: Int, width: Double) {
        if depth <= 0 {
            return
        }

        // Calculate end point
        let endX = x + cos(angle) * length
        let endY = y + sin(angle) * length

        // Set line width for this branch
        context.setLineWidth(max(width, 1.0))

        // Draw the branch
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: endX, y: endY))

        // Draw left branch
        drawBranch(context: context,
                   x: endX,
                   y: endY,
                   length: length * lengthShrink,
                   angle: angle + branchAngle,
                   depth: depth - 1,
                   width: width * 0.8)

        // Draw right branch
        drawBranch(context: context,
                   x: endX,
                   y: endY,
                   length: length * lengthShrink,
                   angle: angle - branchAngle,
                   depth: depth - 1,
                   width: width * 0.8)
    }
}
