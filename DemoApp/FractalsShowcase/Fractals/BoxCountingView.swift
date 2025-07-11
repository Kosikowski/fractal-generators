//
//  BoxCountingView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Box Counting Fractal Dimension Analysis
 *
 * This view demonstrates the box-counting method for estimating fractal dimension.
 * It applies this technique to a Koch Snowflake fractal.
 *
 * Mathematical Foundation:
 * - Fractal dimension D is calculated using the box-counting method
 * - For a fractal, the number of boxes N(ε) of size ε that intersect the fractal
 *   follows the relationship: N(ε) ∝ ε^(-D)
 * - Taking logarithms: log(N(ε)) = -D * log(ε) + constant
 * - The slope of log(N) vs log(1/ε) gives the fractal dimension D
 *
 * For the Koch Snowflake:
 * - Theoretical fractal dimension: D = log(4)/log(3) ≈ 1.2619
 * - The fractal is created by iteratively replacing each line segment with 4 smaller segments
 * - Each iteration increases the perimeter by a factor of 4/3
 *
 * The box-counting method provides a numerical approximation of this theoretical value.
 */

struct BoxCountingView: NSViewRepresentable {
    let fractalIterations: Int // Iterations for the base fractal (Koch Snowflake)
    let boxLevels: Int // Number of box grid levels to show

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateBoxCounting(iterations: fractalIterations)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateBoxCounting(iterations: fractalIterations)
    }

    func generateBoxCounting(iterations: Int) -> NSImage {
        let width = 600
        let height = 600
        let image = NSImage(size: CGSize(width: width, height: height))

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Set background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Generate Koch Snowflake points
        let kochPoints = generateKochSnowflake(iterations: iterations, width: width, height: height)

        // Draw the Koch Snowflake
        context.setStrokeColor(NSColor.white.cgColor)
        context.setLineWidth(1.0)
        context.beginPath()
        context.move(to: kochPoints[0])
        for point in kochPoints.dropFirst() {
            context.addLine(to: point)
        }
        context.closePath()
        context.strokePath()

        // Perform box-counting and draw grids
        context.setStrokeColor(NSColor.red.cgColor)
        context.setLineWidth(0.5)

        var boxCounts: [(size: Double, count: Int)] = []
        for level in 0 ..< boxLevels {
            let boxSize = Double(width) / pow(2.0, Double(level))
            let count = countBoxes(points: kochPoints, boxSize: boxSize, width: width, height: height, context: context)
            boxCounts.append((boxSize, count))
            drawGrid(context: context, boxSize: boxSize, width: width, height: height)
        }

        image.unlockFocus()

        // Print box counts for fractal dimension estimation
        for (size, count) in boxCounts {
            print("Box size: \(size), Boxes intersected: \(count)")
        }

        return image
    }

    // Generate Koch Snowflake points using L-system
    private func generateKochSnowflake(iterations: Int, width: Int, height: Int) -> [CGPoint] {
        let sideLength = Double(width) * 0.5 * pow(1.0 / 3.0, Double(iterations))
        var sequence = "F--F--F" // Initial triangle
        for _ in 0 ..< iterations {
            sequence = sequence.replacingOccurrences(of: "F", with: "F+F--F+F")
        }

        let centerX = Double(width) / 2
        let centerY = Double(height) / 2
        var x = centerX + sideLength * cos(.pi / 2)
        var y = centerY - sideLength * sin(.pi / 2)
        var angle = 0.0
        var points = [CGPoint(x: x, y: y)]

        for char in sequence {
            switch char {
            case "F":
                x += cos(angle) * sideLength
                y += sin(angle) * sideLength
                points.append(CGPoint(x: x, y: y))
            case "+":
                angle += .pi / 3
            case "-":
                angle -= .pi / 3
            default:
                continue
            }
        }
        return points
    }

    // Draw grid of boxes for visualization
    private func drawGrid(context: CGContext, boxSize: Double, width: Int, height: Int) {
        context.beginPath()
        for i in stride(from: 0, to: Double(width), by: boxSize) {
            context.move(to: CGPoint(x: i, y: 0))
            context.addLine(to: CGPoint(x: i, y: Double(height)))
            context.move(to: CGPoint(x: 0, y: i))
            context.addLine(to: CGPoint(x: Double(width), y: i))
        }
        context.strokePath()
    }

    // Count boxes intersecting the fractal
    private func countBoxes(points: [CGPoint], boxSize: Double, width: Int, height _: Int, context _: CGContext) -> Int {
        var occupied = Set<Int>()
        for point in points {
            let gridX = Int(point.x / boxSize)
            let gridY = Int(point.y / boxSize)
            let index = gridY * Int(Double(width) / boxSize) + gridX
            occupied.insert(index)
        }
        return occupied.count
    }

    // Required typealias for NSViewRepresentable
    typealias NSViewType = NSImageView
}
