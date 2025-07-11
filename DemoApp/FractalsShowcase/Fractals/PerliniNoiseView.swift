//
//  PerliniNoiseView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Perlin Noise Fractal
 *
 * Perlin noise is a gradient noise function that produces smooth, natural-looking
 * random patterns. It's widely used in computer graphics for terrain generation,
 * texture synthesis, and other procedural content.
 *
 * Mathematical Foundation:
 * - Uses a grid of random gradient vectors
 * - Interpolates between grid points using smoothstep functions
 * - The noise function is continuous and has no visible grid artifacts
 * - Multiple octaves can be combined to create fractal noise
 *
 * Properties:
 * - Smooth and continuous across all scales
 * - Self-similar when combined with multiple frequencies
 * - Useful for generating natural-looking textures and terrain
 */

struct PerlinNoiseView: NSViewRepresentable {
    let width: Int
    let height: Int
    let scale: CGFloat

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generatePerlinNoise(width: width, height: height, scale: scale)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generatePerlinNoise(width: width, height: height, scale: scale)
    }

    func generatePerlinNoise(width: Int, height: Int, scale: CGFloat) -> NSImage {
        var noise = Array(repeating: Array(repeating: CGFloat(0), count: width), count: height)

        for x in 0 ..< width {
            for y in 0 ..< height {
                let nx = CGFloat(x) / CGFloat(width) * scale
                let ny = CGFloat(y) / CGFloat(height) * scale
                noise[x][y] = perlin(x: nx, y: ny)
            }
        }

        return generateImage(from: noise)
    }

    func generateImage(from noise: [[CGFloat]]) -> NSImage {
        let width = noise.count
        let height = noise[0].count
        let image = NSImage(size: CGSize(width: width, height: height))

        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        for x in 0 ..< width {
            for y in 0 ..< height {
                let intensity = noise[x][y]
                let color = NSColor(white: intensity, alpha: 1.0)
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }

    func perlin(x: CGFloat, y: CGFloat) -> CGFloat {
        let x0 = Int(floor(x))
        let x1 = x0 + 1
        let y0 = Int(floor(y))
        let y1 = y0 + 1

        let sx = x - CGFloat(x0)
        let sy = y - CGFloat(y0)

        let n0 = dotGridGradient(ix: x0, iy: y0, x: x, y: y)
        let n1 = dotGridGradient(ix: x1, iy: y0, x: x, y: y)
        let ix0 = lerp(a: n0, b: n1, t: sx)

        let n2 = dotGridGradient(ix: x0, iy: y1, x: x, y: y)
        let n3 = dotGridGradient(ix: x1, iy: y1, x: x, y: y)
        let ix1 = lerp(a: n2, b: n3, t: sx)

        return lerp(a: ix0, b: ix1, t: sy) * 0.5 + 0.5
    }

    func dotGridGradient(ix: Int, iy: Int, x: CGFloat, y: CGFloat) -> CGFloat {
        let randomAngle = CGFloat(ix * 374_761 + iy * 668_265_263).truncatingRemainder(dividingBy: 360.0) * .pi / 180.0
        let gradient = CGPoint(x: cos(randomAngle), y: sin(randomAngle))
        let dx = x - CGFloat(ix)
        let dy = y - CGFloat(iy)
        return dx * gradient.x + dy * gradient.y
    }

    func lerp(a: CGFloat, b: CGFloat, t: CGFloat) -> CGFloat {
        return a + t * (b - a)
    }
}
