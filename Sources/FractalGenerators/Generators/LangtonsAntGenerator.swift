//
//  LangtonsAntGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Langton's Ant Cellular Automaton Generator
 *
 * Langton's Ant is a simple cellular automaton with these rules:
 * - At a white square, turn 90° right, flip the color, move forward
 * - At a black square, turn 90° left, flip the color, move forward
 *
 * Properties:
 * - Creates a "highway" pattern after initial chaos
 * - Demonstrates emergent order from simple rules
 * - Shows how simple rules can create complex behavior
 * - Fractal-like patterns in the initial chaotic phase
 */

struct LangtonsAntParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let gridSize: Int
    let steps: Int
    init(iterations: Int = 100, size: CGSize = CGSize(width: 600, height: 600), gridSize: Int = 200, steps: Int = 10000) {
        self.iterations = iterations
        self.size = size
        self.gridSize = gridSize
        self.steps = steps
    }
}

struct LangtonsAntGenerator: ImageFractalGenerator {
    typealias Parameters = LangtonsAntParameters
    typealias Output = CGImage

    func generate(with parameters: LangtonsAntParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: LangtonsAntParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        completion(generate(with: parameters))
    }

    func generateImage(with parameters: LangtonsAntParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let cellSize = min(width, height) / parameters.gridSize

        // Initialize grid (all white initially)
        var grid = Array(repeating: Array(repeating: false, count: parameters.gridSize), count: parameters.gridSize)

        // Ant starts at center
        var antX = parameters.gridSize / 2
        var antY = parameters.gridSize / 2
        var antDirection = 0 // 0: up, 1: right, 2: down, 3: left

        // Run simulation
        for _ in 0 ..< parameters.steps {
            let isWhite = !grid[antY][antX]

            if isWhite {
                // Turn right
                antDirection = (antDirection + 1) % 4
            } else {
                // Turn left
                antDirection = (antDirection + 3) % 4
            }

            // Flip color
            grid[antY][antX] = !grid[antY][antX]

            // Move forward
            switch antDirection {
            case 0: antY = (antY - 1 + parameters.gridSize) % parameters.gridSize // up
            case 1: antX = (antX + 1) % parameters.gridSize // right
            case 2: antY = (antY + 1) % parameters.gridSize // down
            case 3: antX = (antX - 1 + parameters.gridSize) % parameters.gridSize // left
            default: break
            }
        }

        // Create image
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Fill background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw cells
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        for i in 0 ..< parameters.gridSize {
            for j in 0 ..< parameters.gridSize {
                if grid[i][j] {
                    let x = j * cellSize
                    let y = (parameters.gridSize - 1 - i) * cellSize
                    context.fill(CGRect(x: x, y: y, width: cellSize, height: cellSize))
                }
            }
        }

        return context.makeImage()!
    }
}
