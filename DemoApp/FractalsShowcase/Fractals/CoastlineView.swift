//
//  CoastlineView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import Foundation
import SwiftUI

/**
 * Fractal Coastline/Mountain Generation
 *
 * This view generates fractal coastlines or mountain profiles using the
 * midpoint displacement algorithm, a classic method for creating natural-looking
 * fractal terrain.
 *
 * Mathematical Foundation:
 * - Uses 1D midpoint displacement to create a fractal line
 * - Starts with a straight line between two endpoints
 * - Iteratively subdivides each segment and displaces the midpoint
 * - The displacement follows: midpoint = average + random(-range, range) * roughness
 * - Range decreases by a factor (typically 0.5) each iteration
 *
 * Algorithm:
 * 1. Initialize endpoints with fixed heights
 * 2. For each iteration:
 *    - Find midpoints of all current segments
 *    - Set midpoint height = average of endpoints + random displacement
 *    - Reduce the displacement range for next iteration
 *
 * Fractal Properties:
 * - Fractal dimension ≈ 1.5 (typical for coastlines)
 * - Self-similar detail at all scales
 * - Creates natural-looking terrain profiles
 * - The roughness parameter controls the jaggedness of the terrain
 *
 * Applications:
 * - Coastline generation (brown land, cyan water)
 * - Mountain range silhouettes
 * - Natural terrain elevation profiles
 */

struct CoastlineMountainView: NSViewRepresentable {
    let iterations: Int
    let roughness: Double // Controls fractal roughness (0.0 to 1.0)

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateFractalTerrain(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateFractalTerrain(iterations: iterations)
    }

    func generateFractalTerrain(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let maxPoints = Int(pow(2.0, Double(iterations))) + 1

        // Initialize height array
        var heights = Array(repeating: 0.0, count: maxPoints)
        heights[0] = Double(height) * 0.5 // Left edge
        heights[maxPoints - 1] = Double(height) * 0.5 // Right edge

        // Midpoint displacement algorithm
        var range = Double(height) * 0.5
        for i in 0 ..< iterations {
            let points = Int(pow(2.0, Double(i)))
            let step = (maxPoints - 1) / points

            for j in stride(from: 0, to: maxPoints - step, by: step) {
                let midIndex = j + step / 2
                let avg = (heights[j] + heights[j + step]) / 2.0
                heights[midIndex] = avg + Double.random(in: -range ... range) * roughness
            }
            range *= pow(0.5, 1.0) // Reduce range each iteration
        }

        // Create image
        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Draw sky
        context.setFillColor(NSColor.cyan.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw terrain
        context.setFillColor(NSColor.brown.cgColor)
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: height))

        // Plot the fractal line and fill below it
        for i in 0 ..< maxPoints {
            let x = Double(width) * Double(i) / Double(maxPoints - 1)
            let y = Double(height) - heights[i]
            context.addLine(to: CGPoint(x: x, y: y))
        }

        context.addLine(to: CGPoint(x: width, y: height))
        context.closePath()
        context.fillPath()

        image.unlockFocus()
        return image
    }
}
