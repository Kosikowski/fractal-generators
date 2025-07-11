//
//  RomanescoBroccoliView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Romanesco Broccoli Fractal
 *
 * Romanesco broccoli exhibits a natural fractal structure with logarithmic spirals
 * and self-similar budding patterns. This view simulates its fractal geometry.
 *
 * Mathematical Foundation:
 * - Uses the golden angle (≈137.5°) for spiral distribution
 * - Each bud spawns multiple smaller buds in a logarithmic spiral
 * - Buds scale down by a factor at each recursion level
 * - The pattern demonstrates phyllotaxis (natural spiral arrangements in plants)
 *
 * Properties:
 * - Self-similar structure at all scales
 * - Logarithmic spiral arrangement mimics natural phyllotaxis
 * - Demonstrates how simple mathematical rules create complex natural forms
 * - Shows the fractal nature of many biological structures
 */

struct RomanescoBroccoliView: NSViewRepresentable {
    let iterations: Int // Recursion depth for budding

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateRomanescoBroccoli(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateRomanescoBroccoli(iterations: iterations)
    }

    func generateRomanescoBroccoli(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let initialRadius = Double(width) * 0.15

        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Set bud color
        context.setFillColor(NSColor.green.cgColor)

        // Center of the broccoli
        let centerX = Double(width) / 2
        let centerY = Double(height) / 2

        // Draw the Romanesco structure
        drawBud(context: context,
                x: centerX,
                y: centerY,
                radius: initialRadius,
                angle: 0,
                depth: iterations)

        image.unlockFocus()
        return image
    }

    private func drawBud(context: CGContext, x: Double, y: Double, radius: Double, angle: Double, depth: Int) {
        if depth <= 0 || radius < 2.0 {
            return
        }

        // Draw current bud as an approximate cone (ellipse for simplicity)
        let budRect = CGRect(x: x - radius * 0.5,
                             y: y - radius,
                             width: radius,
                             height: radius * 2)
        context.fillEllipse(in: budRect)

        // Parameters for spiral budding
        let goldenAngle = .pi * (3 - sqrt(5)) // ≈ 137.5°, the golden angle
        let scaleFactor = 0.7 // Size reduction for child buds
        let numBuds = 5 // Number of buds per level

        // Recursively draw smaller buds in a spiral
        for i in 0 ..< numBuds {
            let newAngle = angle + goldenAngle * Double(i)
            let newRadius = radius * scaleFactor
            let distance = radius * 1.2 // Distance from center for new buds

            let newX = x + cos(newAngle) * distance
            let newY = y + sin(newAngle) * distance

            drawBud(context: context,
                    x: newX,
                    y: newY,
                    radius: newRadius,
                    angle: newAngle,
                    depth: depth - 1)
        }
    }
}
