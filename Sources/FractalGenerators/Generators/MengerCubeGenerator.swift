//
//  MengerCubeGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Menger Cube Fractal Generator
 *
 * The Menger Cube is a 3D fractal created by:
 * - Start with a cube
 * - Divide it into 27 smaller cubes (3x3x3)
 * - Remove the center cube and the 6 face-center cubes
 * - Repeat on the remaining 20 cubes
 *
 * Properties:
 * - Fractal dimension = log(20)/log(3) ≈ 2.727
 * - Self-similar at all scales
 * - Can be represented as 2D projection
 * - Demonstrates 3D fractal geometry
 */

struct MengerCubeParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let depth: Int
    let projectionType: String
    init(iterations: Int = 100, size: CGSize = CGSize(width: 600, height: 600), depth: Int = 2, projectionType: String = "isometric") {
        self.iterations = iterations
        self.size = size
        self.depth = depth
        self.projectionType = projectionType
    }
}

struct MengerCubeGenerator: ImageFractalGenerator {
    typealias Parameters = MengerCubeParameters
    typealias Output = CGImage

    func generate(with parameters: MengerCubeParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: MengerCubeParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        completion(generate(with: parameters))
    }

    func generateImage(with parameters: MengerCubeParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Fill background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw Menger Cube projection
        context.setFillColor(CGColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1))
        context.setStrokeColor(CGColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1))
        context.setLineWidth(1.0)

        let centerX = width / 2
        let centerY = height / 2
        let maxSize = min(width, height) / 3

        drawMengerCubeProjection(context: context, x: centerX, y: centerY, size: maxSize, depth: parameters.depth)

        return context.makeImage()!
    }

    private func drawMengerCubeProjection(context: CGContext, x: Int, y: Int, size: Int, depth: Int) {
        if depth == 0 {
            // Draw a simple cube representation
            let halfSize = size / 2
            let rect = CGRect(x: x - halfSize, y: y - halfSize, width: size, height: size)
            context.fill(rect)
            context.stroke(rect)
            return
        }

        let subSize = size / 3

        // Draw the 20 cubes (excluding center and face centers)
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                for k in 0 ..< 3 {
                    // Skip center cube and face-center cubes
                    let isCenter = (i == 1 && j == 1 && k == 1)
                    let isFaceCenter = ((i == 1 && j == 1) || (i == 1 && k == 1) || (j == 1 && k == 1))

                    if !isCenter && !isFaceCenter {
                        let newX = x + (i - 1) * subSize
                        let newY = y + (j - 1) * subSize
                        drawMengerCubeProjection(context: context, x: newX, y: newY, size: subSize, depth: depth - 1)
                    }
                }
            }
        }
    }
}
