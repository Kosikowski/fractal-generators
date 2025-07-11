//
//  FBMView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import SwiftUI

/**
 * Fractional Brownian Motion (fBm) Terrain Generation
 *
 * Fractional Brownian Motion is a mathematical model for generating
 * natural-looking fractal terrain. It's based on Brownian motion but
 * with controlled fractal properties.
 *
 * Mathematical Foundation:
 * - fBm is defined as: B_H(t) = ∫₀ᵗ (t-s)^(H-1/2) dB(s)
 * - H is the Hurst exponent (0 < H < 1)
 * - For terrain generation, we use the spectral synthesis method:
 *   f(x,y) = Σᵢ Aᵢ × noise(fᵢ × x, fᵢ × y)
 *
 * Where:
 * - Aᵢ = 2^(-H×i) (amplitude decay)
 * - fᵢ = 2ⁱ (frequency increase)
 * - noise() is a smooth noise function
 *
 * Parameters:
 * - H < 0.5: Rough, jagged surfaces (anti-persistent)
 * - H = 0.5: Standard Brownian motion
 * - H > 0.5: Smooth, persistent surfaces
 *
 * Fractal Properties:
 * - Fractal dimension = 3 - H
 * - Self-similar at all scales
 * - Creates realistic terrain with natural roughness
 * - Multiple octaves provide detail at different scales
 */

struct FBMView: NSViewRepresentable {
    let octaves: Int // Number of noise layers
    let hurst: Double // Hurst exponent (0 < H < 1)

    func makeNSView(context _: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.image = generateFBM(octaves: octaves, hurst: hurst)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context _: Context) {
        nsView.image = generateFBM(octaves: octaves, hurst: hurst)
    }

    func generateFBM(octaves: Int, hurst: Double) -> NSImage {
        let width = 600
        let height = 600
        let image = NSImage(size: CGSize(width: width, height: height))

        // Initialize heightmap
        var heightmap = Array(repeating: Array(repeating: 0.0, count: width), count: height)

        // fBm parameters
        let lacunarity = 2.0 // Frequency multiplier per octave
        let gain = pow(2.0, -hurst) // Amplitude decay per octave

        // Generate noise layers
        for octave in 0 ..< octaves {
            let frequency = pow(lacunarity, Double(octave))
            let amplitude = pow(gain, Double(octave))

            for y in 0 ..< height {
                for x in 0 ..< width {
                    let nx = Double(x) / Double(width) * frequency
                    let ny = Double(y) / Double(height) * frequency
                    heightmap[y][x] += noise(x: nx, y: ny) * amplitude
                }
            }
        }

        // Create image
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext

        // Normalize heightmap for coloring
        var minHeight = heightmap[0][0]
        var maxHeight = heightmap[0][0]
        for y in 0 ..< height {
            for x in 0 ..< width {
                minHeight = min(minHeight, heightmap[y][x])
                maxHeight = max(maxHeight, heightmap[y][x])
            }
        }

        // Draw as a colored heightmap
        for y in 0 ..< height {
            for x in 0 ..< width {
                let heightValue = (heightmap[y][x] - minHeight) / (maxHeight - minHeight)
                let color: NSColor
                if heightValue < 0.3 {
                    color = NSColor.blue // Water
                } else if heightValue < 0.7 {
                    color = NSColor.green // Land
                } else {
                    color = NSColor.brown // Mountains
                }
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        image.unlockFocus()
        return image
    }

    // Simple Perlin-like noise function (for demonstration)
    private func noise(x: Double, y: Double) -> Double {
        let n = Int(x * 12345.6789 + y * 98765.4321)
        let seed = Double(n & 0x7FFF_FFFF) / Double(0x7FFF_FFFF)
        return seed * 2.0 - 1.0 // Range [-1, 1]
    }
}
