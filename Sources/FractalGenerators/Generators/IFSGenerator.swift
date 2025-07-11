//
//  IFSGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Iterated Function System (IFS) Fractal Generator
 *
 * IFS uses affine transformations to create self-similar fractal patterns.
 * Each transformation is applied with a certain probability, creating
 * complex structures from simple rules.
 *
 * Properties:
 * - Creates self-similar patterns
 * - Uses affine transformations
 * - Demonstrates chaos game algorithm
 * - Can create various fractal shapes
 */

struct IFSGenerator: ImageFractalGenerator {
    typealias Parameters = RecursiveFractalParameters
    typealias Output = CGImage

    func generate(with parameters: RecursiveFractalParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: RecursiveFractalParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        completion(generate(with: parameters))
    }

    func generateImage(with parameters: RecursiveFractalParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        // Define Sierpinski Triangle transformations
        let transformations = [
            (probability: 0.33, matrix: [[0.5, 0.0], [0.0, 0.5]], translation: [0.0, 0.0]),
            (probability: 0.33, matrix: [[0.5, 0.0], [0.0, 0.5]], translation: [0.5, 0.0]),
            (probability: 0.34, matrix: [[0.5, 0.0], [0.0, 0.5]], translation: [0.25, 0.433]),
        ]

        // Initialize point at center
        var point = CGPoint(x: 0.5, y: 0.5)
        var points: [CGPoint] = []

        // Generate points using chaos game
        for _ in 0 ..< parameters.iterations {
            // Choose transformation based on probabilities
            let random = Double.random(in: 0 ... 1)
            var cumulative = 0.0
            var selectedIndex = 0

            for (index, transform) in transformations.enumerated() {
                cumulative += transform.probability
                if random <= cumulative {
                    selectedIndex = index
                    break
                }
            }

            // Apply transformation
            let transform = transformations[selectedIndex]
            point = applyTransformation(point: point, matrix: transform.matrix, translation: transform.translation)
            points.append(point)
        }

        // Create image
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Fill background
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw points
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        for point in points {
            let x = Int(point.x * Double(width))
            let y = Int(point.y * Double(height))

            if x >= 0 && x < width && y >= 0 && y < height {
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        return context.makeImage()!
    }

    private func applyTransformation(point: CGPoint, matrix: [[Double]], translation: [Double]) -> CGPoint {
        let x = point.x
        let y = point.y

        // Apply matrix transformation
        let newX = matrix[0][0] * x + matrix[0][1] * y + translation[0]
        let newY = matrix[1][0] * x + matrix[1][1] * y + translation[1]

        return CGPoint(x: newX, y: newY)
    }
}
