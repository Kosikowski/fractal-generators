//
//  VoronoiDiagramGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/**
 * Voronoi Diagram Fractal Generator
 *
 * A Voronoi diagram partitions space into regions based on distance
 * to a set of seed points. Each region contains all points closest
 * to one seed point.
 *
 * Properties:
 * - Creates cellular patterns
 * - Each cell is a polygon
 * - Demonstrates spatial partitioning
 * - Can create natural-looking textures
 */

struct VoronoiDiagramParameters: FractalParameters {
    let iterations: Int
    let size: CGSize
    let numSeeds: Int
    let seedRadius: Double
    init(iterations: Int = 100, size: CGSize = CGSize(width: 600, height: 600), numSeeds: Int = 20, seedRadius: Double = 5.0) {
        self.iterations = iterations
        self.size = size
        self.numSeeds = numSeeds
        self.seedRadius = seedRadius
    }
}

struct VoronoiDiagramGenerator: ImageFractalGenerator {
    typealias Parameters = VoronoiDiagramParameters
    typealias Output = CGImage

    func generate(with parameters: VoronoiDiagramParameters) -> CGImage {
        generateImage(with: parameters)
    }

    func generateAsync(with parameters: VoronoiDiagramParameters, progress _: @escaping (Double) -> Void, completion: @escaping (CGImage) -> Void) {
        completion(generate(with: parameters))
    }

    func generateImage(with parameters: VoronoiDiagramParameters) -> CGImage {
        let width = Int(parameters.size.width)
        let height = Int(parameters.size.height)

        // Generate random seed points
        var seeds: [CGPoint] = []
        for _ in 0 ..< parameters.numSeeds {
            let x = Double.random(in: 0 ... Double(width))
            let y = Double.random(in: 0 ... Double(height))
            seeds.append(CGPoint(x: x, y: y))
        }

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        // Fill background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Generate Voronoi cells
        for y in 0 ..< height {
            for x in 0 ..< width {
                let point = CGPoint(x: x, y: y)
                let closestSeed = findClosestSeed(point: point, seeds: seeds)
                let seedIndex = seeds.firstIndex(of: closestSeed) ?? 0

                // Color based on seed index
                let hue = Double(seedIndex) / Double(seeds.count)
                let color = CGColor(red: CGFloat(hue),
                                    green: CGFloat(0.5 + hue * 0.5),
                                    blue: CGFloat(1.0 - hue),
                                    alpha: 1.0)

                context.setFillColor(color)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        // Draw seed points
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        for seed in seeds {
            let rect = CGRect(x: seed.x - parameters.seedRadius,
                              y: seed.y - parameters.seedRadius,
                              width: parameters.seedRadius * 2,
                              height: parameters.seedRadius * 2)
            context.fillEllipse(in: rect)
        }

        return context.makeImage()!
    }

    private func findClosestSeed(point: CGPoint, seeds: [CGPoint]) -> CGPoint {
        var closestSeed = seeds[0]
        var minDistance = distance(from: point, to: seeds[0])

        for seed in seeds {
            let dist = distance(from: point, to: seed)
            if dist < minDistance {
                minDistance = dist
                closestSeed = seed
            }
        }

        return closestSeed
    }

    private func distance(from point1: CGPoint, to point2: CGPoint) -> Double {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }
}
