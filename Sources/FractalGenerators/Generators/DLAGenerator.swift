//
//  DLAGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Diffusion Limited Aggregation (DLA) Fractal Generator
 *
 * DLA simulates the growth of clusters through random particle diffusion.
 * Particles start from the edge and move randomly until they stick to
 * the growing cluster.
 *
 * Properties:
 * - Creates dendritic, tree-like structures
 * - Demonstrates fractal growth patterns
 * - Fractal dimension ≈ 1.7
 * - Self-similar at different scales
 */

// Custom point struct that's Hashable
struct HashablePoint: Hashable {
    let x: Double
    let y: Double

    init(_ point: CGPoint) {
        x = point.x
        y = point.y
    }

    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

struct DLAParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let numParticles: Int
    let stickiness: Double
    init(iterations: Int = 100, size: CGSize = CGSize(width: 600, height: 600), numParticles: Int = 1000, stickiness: Double = 0.1) {
        self.iterations = iterations
        self.size = size
        self.numParticles = numParticles
        self.stickiness = stickiness
    }
}

struct DLAGenerator: ImageFractalGenerator {
    typealias Parameters = DLAParameters
    typealias Output = CGImage

    func generate(with parameters: DLAParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: DLAParameters, progress _: @escaping @Sendable (Double) -> Void, completion: @escaping @Sendable (CGImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.generate(with: parameters)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    func generateImage(with parameters: DLAParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        // Initialize cluster with center seed
        var cluster: Set<HashablePoint> = [HashablePoint(CGPoint(x: width / 2, y: height / 2))]

        // Generate particles
        for _ in 0 ..< parameters.numParticles {
            // Start particle from random edge
            let particle = startParticleFromEdge(width: width, height: height)
            var currentParticle = particle

            // Move particle until it sticks or escapes
            while cluster.count < parameters.numParticles {
                // Random walk
                let dx = Int.random(in: -1 ... 1)
                let dy = Int.random(in: -1 ... 1)
                let newX = currentParticle.x + Double(dx)
                let newY = currentParticle.y + Double(dy)

                // Check bounds
                if newX < 0 || newX >= Double(width) || newY < 0 || newY >= Double(height) {
                    break // Particle escaped
                }

                currentParticle = HashablePoint(CGPoint(x: newX, y: newY))

                // Check if particle is adjacent to cluster
                if isAdjacentToCluster(point: currentParticle, cluster: cluster) {
                    // Probability of sticking
                    if Double.random(in: 0 ... 1) < parameters.stickiness {
                        cluster.insert(currentParticle)
                        break
                    }
                }
            }
        }

        // Create image
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Fill background
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw cluster
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        for point in cluster {
            let cgPoint = point.cgPoint
            context.fill(CGRect(x: cgPoint.x, y: cgPoint.y, width: 1, height: 1))
        }

        return context.makeImage()!
    }

    private func startParticleFromEdge(width: Int, height: Int) -> HashablePoint {
        let side = Int.random(in: 0 ... 3)
        switch side {
        case 0: // Top
            return HashablePoint(CGPoint(x: Double.random(in: 0 ... Double(width)), y: 0))
        case 1: // Right
            return HashablePoint(CGPoint(x: Double(width), y: Double.random(in: 0 ... Double(height))))
        case 2: // Bottom
            return HashablePoint(CGPoint(x: Double.random(in: 0 ... Double(width)), y: Double(height)))
        case 3: // Left
            return HashablePoint(CGPoint(x: 0, y: Double.random(in: 0 ... Double(height))))
        default:
            return HashablePoint(CGPoint(x: 0, y: 0))
        }
    }

    private func isAdjacentToCluster(point: HashablePoint, cluster: Set<HashablePoint>) -> Bool {
        for dx in -1 ... 1 {
            for dy in -1 ... 1 {
                if dx == 0 && dy == 0 { continue }
                let adjacentPoint = HashablePoint(CGPoint(x: point.x + Double(dx), y: point.y + Double(dy)))
                if cluster.contains(adjacentPoint) {
                    return true
                }
            }
        }
        return false
    }
}
