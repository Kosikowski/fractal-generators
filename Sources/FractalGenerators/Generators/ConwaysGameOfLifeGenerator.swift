//
//  ConwaysGameOfLifeGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Conway's Game of Life Cellular Automaton Generator
 *
 * Conway's Game of Life is a cellular automaton with simple rules:
 * - Any live cell with 2 or 3 neighbors survives
 * - Any dead cell with exactly 3 neighbors becomes alive
 * - All other cells die or stay dead
 *
 * Properties:
 * - Demonstrates emergent complexity from simple rules
 * - Can create stable patterns, oscillators, and gliders
 * - Turing complete - can simulate any computer
 * - Fractal-like self-similar patterns at different scales
 */

struct ConwaysGameOfLifeParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let gridSize: Int
    let initialDensity: Double
    let steps: Int
    init(iterations: Int = 100, size: CGSize = CGSize(width: 600, height: 600), gridSize: Int = 100, initialDensity: Double = 0.3, steps: Int = 50) {
        self.iterations = iterations
        self.size = size
        self.gridSize = gridSize
        self.initialDensity = initialDensity
        self.steps = steps
    }
}

struct ConwaysGameOfLifeGenerator: ImageFractalGenerator {
    typealias Parameters = ConwaysGameOfLifeParameters
    typealias Output = CGImage

    func generate(with parameters: ConwaysGameOfLifeParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: ConwaysGameOfLifeParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        completion(generate(with: parameters))
    }

    func generateImage(with parameters: ConwaysGameOfLifeParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let cellSize = min(width, height) / parameters.gridSize

        // Initialize grid with random cells
        var grid = Array(repeating: Array(repeating: false, count: parameters.gridSize), count: parameters.gridSize)
        for i in 0 ..< parameters.gridSize {
            for j in 0 ..< parameters.gridSize {
                grid[i][j] = Double.random(in: 0 ... 1) < parameters.initialDensity
            }
        }

        // Run simulation for specified steps
        for _ in 0 ..< parameters.steps {
            grid = nextGeneration(grid: grid)
        }

        // Create image from final state
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Fill background
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw cells
        context.setFillColor(CGColor(red: 0, green: 1, blue: 0, alpha: 1))
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

    private func nextGeneration(grid: [[Bool]]) -> [[Bool]] {
        let size = grid.count
        var newGrid = Array(repeating: Array(repeating: false, count: size), count: size)

        for i in 0 ..< size {
            for j in 0 ..< size {
                let neighbors = countNeighbors(grid: grid, row: i, col: j)
                let isAlive = grid[i][j]

                if isAlive {
                    // Survival: 2 or 3 neighbors
                    newGrid[i][j] = neighbors == 2 || neighbors == 3
                } else {
                    // Birth: exactly 3 neighbors
                    newGrid[i][j] = neighbors == 3
                }
            }
        }

        return newGrid
    }

    private func countNeighbors(grid: [[Bool]], row: Int, col: Int) -> Int {
        let size = grid.count
        var count = 0

        for di in -1 ... 1 {
            for dj in -1 ... 1 {
                if di == 0 && dj == 0 { continue }

                let ni = (row + di + size) % size
                let nj = (col + dj + size) % size

                if grid[ni][nj] {
                    count += 1
                }
            }
        }

        return count
    }
}
