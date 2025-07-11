//
//  BurningShipGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import CoreGraphics
import Foundation
import SwiftUI

/// Burning Ship Fractal Generator
struct BurningShipGenerator: ImageFractalGenerator, ProgressiveFractalGenerator {
    func generate(with parameters: ComplexPlaneParameters) -> CGImage {
        return generateImage(with: parameters)
    }

    func generateAsync(with parameters: ComplexPlaneParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.generateImage(with: parameters)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    func generateImage(with parameters: ComplexPlaneParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return createErrorImage(size: parameters.size)
        }
        let zoom = 1.5
        for x in 0 ..< width {
            for y in 0 ..< height {
                let cx = (Double(x) - Double(width) / 2) / (Double(width) / zoom)
                let cy = (Double(y) - Double(height) / 2) / (Double(height) / zoom)
                let color = burningShipColor(cx: cx, cy: cy, iterations: parameters.iterations)
                context.setFillColor(color.cgColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1))
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        guard let image = context.makeImage() else {
            return createErrorImage(size: parameters.size)
        }
        return image
    }

    func generateProgressive(with parameters: ComplexPlaneParameters, onProgress: @escaping (CGImage, Double) -> Void) {
        let progressiveSteps = [0.25, 0.5, 0.75, 1.0]
        for (index, scale) in progressiveSteps.enumerated() {
            let scaledSize = CGSize(width: parameters.size.width * scale, height: parameters.size.height * scale)
            let scaledParameters = ComplexPlaneParameters(
                iterations: parameters.iterations,
                size: scaledSize,
                viewRect: parameters.viewRect,
                blockiness: parameters.blockiness
            )
            let image = generateImage(with: scaledParameters)
            let progress = Double(index + 1) / Double(progressiveSteps.count)
            DispatchQueue.main.async {
                onProgress(image, progress)
            }
        }
    }

    private func burningShipColor(cx: Double, cy: Double, iterations: Int) -> Color {
        var z = Complex(0.0, 0.0)
        let c = Complex(cx, cy)
        var iter = 0
        while iter < iterations && z.lengthSquared < 4.0 {
            z = Complex(abs(z.real), abs(z.imaginary)) * Complex(abs(z.real), abs(z.imaginary)) + c
            iter += 1
        }
        let colorFactor = Double(iter) / Double(iterations)
        if iter >= iterations {
            return .black
        } else {
            return Color(hue: colorFactor, saturation: 1.0, brightness: 1.0)
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
