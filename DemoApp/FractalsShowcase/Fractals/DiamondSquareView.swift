//
//  DiamondSquareView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Diamond-Square Terrain Generation Algorithm
 *
 * The Diamond-Square algorithm is a procedural terrain generation technique
 * that creates realistic fractal landscapes. It's an improvement over the
 * basic midpoint displacement method.
 *
 * Mathematical Foundation:
 * - Creates a heightmap of size 2^n + 1 (e.g., 65x65 for n=6)
 * - Uses two alternating steps: Diamond and Square
 *
 * Diamond Step:
 * - For each square, set the center point to the average of the four corners
 * - Add random noise: center = average + random(-scale, scale)
 *
 * Square Step:
 * - For each diamond, set the center point to the average of the four surrounding points
 * - Add random noise: center = average + random(-scale, scale)
 *
 * The algorithm iteratively reduces the step size by half and the noise scale
 * by a factor (typically 0.5), creating fractal detail at all scales.
 *
 * Fractal Properties:
 * - Fractal dimension ≈ 2.5 (typical for terrain)
 * - Self-similar roughness at all scales
 * - Produces natural-looking landscapes with realistic elevation patterns
 */

struct DiamondSquareView: NSViewRepresentable {
    let iterations: Int // Determines grid size (2^iterations + 1)

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateDiamondSquare(iterations: iterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateDiamondSquare(iterations: iterations)
    }

    func generateDiamondSquare(iterations: Int) -> NSImage {
        let size = Int(pow(2.0, Double(iterations))) + 1 // Grid size (e.g., 5 for 2 iterations)
        let width = 600
        let height = 600

        // Initialize heightmap
        var heightmap = Array(repeating: Array(repeating: 0.0, count: size), count: size)

        // Set initial corner values
        heightmap[0][0] = Double.random(in: 0 ... 1)
        heightmap[0][size - 1] = Double.random(in: 0 ... 1)
        heightmap[size - 1][0] = Double.random(in: 0 ... 1)
        heightmap[size - 1][size - 1] = Double.random(in: 0 ... 1)

        // Perform Diamond-Square algorithm
        var stepSize = size - 1
        var scale = 1.0 // Initial random range

        while stepSize > 1 {
            // Diamond step: set center of each square
            for i in stride(from: 0, to: size - stepSize, by: stepSize) {
                for j in stride(from: 0, to: size - stepSize, by: stepSize) {
                    let midX = i + stepSize / 2
                    let midY = j + stepSize / 2
                    let avg = (heightmap[i][j] + heightmap[i + stepSize][j] +
                        heightmap[i][j + stepSize] + heightmap[i + stepSize][j + stepSize]) / 4.0
                    heightmap[midX][midY] = avg + Double.random(in: -scale ... scale)
                }
            }

            // Square step: set center of each diamond
            for i in stride(from: 0, to: size, by: stepSize / 2) {
                for j in stride(from: i % stepSize == 0 ? stepSize / 2 : 0, to: size, by: stepSize) {
                    var sum = 0.0
                    var count = 0

                    // Average of four surrounding points (if within bounds)
                    if i >= stepSize / 2 { // Top
                        sum += heightmap[i - stepSize / 2][j]
                        count += 1
                    }
                    if i + stepSize / 2 < size { // Bottom
                        sum += heightmap[i + stepSize / 2][j]
                        count += 1
                    }
                    if j >= stepSize / 2 { // Left
                        sum += heightmap[i][j - stepSize / 2]
                        count += 1
                    }
                    if j + stepSize / 2 < size { // Right
                        sum += heightmap[i][j + stepSize / 2]
                        count += 1
                    }

                    if count > 0 {
                        heightmap[i][j] = sum / Double(count) + Double.random(in: -scale ... scale)
                    }
                }
            }

            stepSize /= 2
            scale *= 0.5 // Reduce random range for smoother transitions
        }

        // Create image
        let image = NSImage(size: CGSize(width: width, height: height))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Normalize heightmap for coloring
        var minHeight = heightmap[0][0]
        var maxHeight = heightmap[0][0]
        for i in 0 ..< size {
            for j in 0 ..< size {
                minHeight = min(minHeight, heightmap[i][j])
                maxHeight = max(maxHeight, heightmap[i][j])
            }
        }

        // Draw terrain with color coding
        for i in 0 ..< size {
            for j in 0 ..< size {
                let heightValue = (heightmap[i][j] - minHeight) / (maxHeight - minHeight)
                let color: NSColor
                if heightValue < 0.3 {
                    color = NSColor.blue // Water
                } else if heightValue < 0.7 {
                    color = NSColor.green // Land
                } else {
                    color = NSColor.white // Mountains
                }
                context.setFillColor(color.cgColor)
                let px = Double(i) * Double(width) / Double(size - 1)
                let py = Double(j) * Double(height) / Double(size - 1)
                context.fill(CGRect(x: px, y: py, width: Double(width) / Double(size), height: Double(height) / Double(size)))
            }
        }

        image.unlockFocus()
        return image
    }
}
