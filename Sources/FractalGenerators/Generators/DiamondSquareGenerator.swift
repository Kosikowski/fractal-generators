//
//  DiamondSquareGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Diamond-Square Fractal Generator
struct DiamondSquareGenerator: ImageFractalGenerator, ProgressiveFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateAsync(with parameters: RecursiveFractalParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.generateImage(with: parameters)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    func generateImage(with parameters: RecursiveFractalParameters) -> CGImage {
        let iterations = parameters.depth
        let size = Int(pow(2.0, Double(iterations))) + 1
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        var heightmap = Array(repeating: Array(repeating: 0.0, count: size), count: size)
        heightmap[0][0] = Double.random(in: 0 ... 1)
        heightmap[0][size - 1] = Double.random(in: 0 ... 1)
        heightmap[size - 1][0] = Double.random(in: 0 ... 1)
        heightmap[size - 1][size - 1] = Double.random(in: 0 ... 1)
        var stepSize = size - 1
        var scale = 1.0
        while stepSize > 1 {
            for i in stride(from: 0, to: size - stepSize, by: stepSize) {
                for j in stride(from: 0, to: size - stepSize, by: stepSize) {
                    let midX = i + stepSize / 2
                    let midY = j + stepSize / 2
                    let avg = (heightmap[i][j] + heightmap[i + stepSize][j] + heightmap[i][j + stepSize] + heightmap[i + stepSize][j + stepSize]) / 4.0
                    heightmap[midX][midY] = avg + Double.random(in: -scale ... scale)
                }
            }
            for i in stride(from: 0, to: size, by: stepSize / 2) {
                for j in stride(from: i % stepSize == 0 ? stepSize / 2 : 0, to: size, by: stepSize) {
                    var sum = 0.0
                    var count = 0
                    if i >= stepSize / 2 { sum += heightmap[i - stepSize / 2][j]; count += 1 }
                    if i + stepSize / 2 < size { sum += heightmap[i + stepSize / 2][j]; count += 1 }
                    if j >= stepSize / 2 { sum += heightmap[i][j - stepSize / 2]; count += 1 }
                    if j + stepSize / 2 < size { sum += heightmap[i][j + stepSize / 2]; count += 1 }
                    if count > 0 {
                        heightmap[i][j] = sum / Double(count) + Double.random(in: -scale ... scale)
                    }
                }
            }
            stepSize /= 2
            scale *= 0.5
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return createErrorImage(size: parameters.size)
        }
        var minHeight = heightmap[0][0]
        var maxHeight = heightmap[0][0]
        for i in 0 ..< size {
            for j in 0 ..< size {
                minHeight = min(minHeight, heightmap[i][j])
                maxHeight = max(maxHeight, heightmap[i][j])
            }
        }
        for i in 0 ..< size {
            for j in 0 ..< size {
                let heightValue = (heightmap[i][j] - minHeight) / (maxHeight - minHeight)
                let color: Color
                if heightValue < 0.3 {
                    color = .blue
                } else if heightValue < 0.7 {
                    color = .green
                } else {
                    color = .white
                }
                context.setFillColor(color.cgColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1))
                let px = Double(i) * Double(width) / Double(size - 1)
                let py = Double(j) * Double(height) / Double(size - 1)
                context.fill(CGRect(x: px, y: py, width: Double(width) / Double(size), height: Double(height) / Double(size)))
            }
        }
        guard let image = context.makeImage() else {
            return createErrorImage(size: parameters.size)
        }
        return image
    }

    func generateProgressive(with parameters: RecursiveFractalParameters, onProgress: @escaping (CGImage, Double) -> Void) {
        let progressiveSteps = [0.25, 0.5, 0.75, 1.0]
        for (index, scale) in progressiveSteps.enumerated() {
            let scaledSize = CGSize(width: parameters.size.width * scale, height: parameters.size.height * scale)
            let scaledParameters = RecursiveFractalParameters(
                iterations: parameters.iterations,
                size: scaledSize,
                depth: parameters.depth
            )
            let image = generateImage(with: scaledParameters)
            let progress = Double(index + 1) / Double(progressiveSteps.count)
            DispatchQueue.main.async {
                onProgress(image, progress)
            }
        }
    }

    private func createErrorImage(size: CGSize) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width) * 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError("Failed to create error image context")
        }
        context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(origin: .zero, size: size))
        guard let image = context.makeImage() else {
            fatalError("Failed to create error image")
        }
        return image
    }
}
