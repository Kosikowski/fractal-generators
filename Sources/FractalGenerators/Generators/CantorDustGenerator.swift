//
//  CantorDustGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Cantor Dust (2D Cantor Set) Fractal Generator
 *
 * Cantor Dust is the 2D version of the Cantor Set, created by:
 * - Start with a square
 * - Divide it into 9 smaller squares (3x3 grid)
 * - Remove the center square
 * - Repeat on the remaining 8 squares
 *
 * Properties:
 * - Fractal dimension = log(8)/log(3) ≈ 1.893
 * - Self-similar at all scales
 * - Totally disconnected (no connected components)
 * - Perfect (every point is a limit point)
 */

struct CantorDustParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let depth: Int
    init(iterations: Int = 100, size: CGSize = CGSize(width: 600, height: 600), depth: Int = 4) {
        self.iterations = iterations
        self.size = size
        self.depth = depth
    }
}

struct CantorDustGenerator: ImageFractalGenerator {
    typealias Parameters = CantorDustParameters
    typealias Output = CGImage

    func generate(with parameters: CantorDustParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: CantorDustParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        completion(generate(with: parameters))
    }

    func generateImage(with parameters: CantorDustParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Fill background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw Cantor Dust
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        drawCantorDust(context: context, x: 0, y: 0, size: min(width, height), depth: parameters.depth)

        return context.makeImage()!
    }

    private func drawCantorDust(context: CGContext, x: Int, y: Int, size: Int, depth: Int) {
        if depth == 0 {
            // Draw the square
            context.fill(CGRect(x: x, y: y, width: size, height: size))
            return
        }

        let subSize = size / 3

        // Draw the 8 squares (excluding the center)
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                if !(i == 1 && j == 1) { // Skip center square
                    let newX = x + i * subSize
                    let newY = y + j * subSize
                    drawCantorDust(context: context, x: newX, y: newY, size: subSize, depth: depth - 1)
                }
            }
        }
    }
}
