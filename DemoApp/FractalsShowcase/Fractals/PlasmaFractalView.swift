//
//  PlasmaFractalView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Plasma Fractal Generation
 *
 * The Plasma Fractal is a procedural terrain generation technique that creates
 * natural-looking landscapes using the diamond-square algorithm with random noise.
 *
 * Mathematical Foundation:
 * - Uses the diamond-square algorithm on a 2^n + 1 grid
 * - Diamond step: sets center of each square to average of corners + random noise
 * - Square step: sets midpoints of edges to average of surrounding points + noise
 * - Noise amplitude decreases by a roughness factor each iteration
 *
 * Properties:
 * - Creates smooth, natural-looking terrain
 * - Self-similar at all scales
 * - Adjustable roughness controls terrain jaggedness
 * - Useful for procedural landscape generation
 */

struct PlasmaFractalView: NSViewRepresentable {
    let size: Int
    let roughness: CGFloat

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generatePlasmaFractal(size: size, roughness: roughness)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generatePlasmaFractal(size: size, roughness: roughness)
    }

    func generatePlasmaFractal(size: Int, roughness: CGFloat) -> NSImage {
        let dimension = (1 << size) + 1 // Ensure power of 2 plus 1 size
        var heightMap = Array(repeating: Array(repeating: CGFloat(0), count: dimension), count: dimension)

        // Set initial corner values
        heightMap[0][0] = CGFloat.random(in: 0 ... 1)
        heightMap[0][dimension - 1] = CGFloat.random(in: 0 ... 1)
        heightMap[dimension - 1][0] = CGFloat.random(in: 0 ... 1)
        heightMap[dimension - 1][dimension - 1] = CGFloat.random(in: 0 ... 1)

        var stepSize = dimension - 1
        var scale = roughness

        while stepSize > 1 {
            let halfStep = stepSize / 2

            // Diamond step
            for x in stride(from: 0, to: dimension - 1, by: stepSize) {
                for y in stride(from: 0, to: dimension - 1, by: stepSize) {
                    let avg = (heightMap[x][y] +
                        heightMap[x + stepSize][y] +
                        heightMap[x][y + stepSize] +
                        heightMap[x + stepSize][y + stepSize]) / 4
                    heightMap[x + halfStep][y + halfStep] = avg + CGFloat.random(in: -scale ... scale)
                }
            }

            // Square step
            for x in stride(from: 0, to: dimension, by: halfStep) {
                for y in stride(from: (x + halfStep) % stepSize, to: dimension, by: stepSize) {
                    var sum: CGFloat = 0
                    var count: CGFloat = 0

                    if x - halfStep >= 0 { sum += heightMap[x - halfStep][y]; count += 1 }
                    if x + halfStep < dimension { sum += heightMap[x + halfStep][y]; count += 1 }
                    if y - halfStep >= 0 { sum += heightMap[x][y - halfStep]; count += 1 }
                    if y + halfStep < dimension { sum += heightMap[x][y + halfStep]; count += 1 }

                    heightMap[x][y] = (sum / count) + CGFloat.random(in: -scale ... scale)
                }
            }

            stepSize /= 2
            scale *= roughness
        }

        return generateImage(from: heightMap)
    }

    func generateImage(from heightMap: [[CGFloat]]) -> NSImage {
        let dimension = heightMap.count
        let image = NSImage(size: CGSize(width: dimension, height: dimension))

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        for x in 0 ..< dimension {
            for y in 0 ..< dimension {
                let intensity = heightMap[x][y]
                let color = NSColor(hue: intensity, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }
}
