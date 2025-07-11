//
//  KochSnowflake.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import Foundation
import SwiftUI

/**
 * Koch Snowflake Fractal
 *
 * The Koch Snowflake is a fractal curve created by applying the Koch curve
 * construction to each side of an equilateral triangle. It's one of the earliest
 * fractals discovered and demonstrates how simple rules create complex patterns.
 *
 * Mathematical Foundation:
 * - Start with an equilateral triangle
 * - Replace each side with a Koch curve
 * - The Koch curve rule: divide each line into thirds, replace middle third
 *   with two sides of an equilateral triangle
 * - Each iteration adds more detail to the boundary
 * - The process continues recursively to the desired depth
 *
 * Properties:
 * - Fractal dimension = log(4)/log(3) ≈ 1.262
 * - Self-similar at all scales
 * - Has finite area but infinite perimeter
 * - Exhibits perfect six-fold symmetry
 */

struct KochSnowflakeView: View {
    let iterations: Int

    var body: some View {
        Canvas { context, size in
            let triangle = initialTriangle(in: size)
            let snowflakePath = kochSnowflakePath(from: triangle, iterations: iterations)

            context.stroke(snowflakePath, with: .color(.blue), lineWidth: 2)
        }
        .background(Color.white)
    }

    func initialTriangle(in size: CGSize) -> [CGPoint] {
        let width = min(size.width, size.height) * 0.8
        let height = width * sqrt(3) / 2
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        let p1 = CGPoint(x: center.x, y: center.y - height / 2)
        let p2 = CGPoint(x: center.x - width / 2, y: center.y + height / 2)
        let p3 = CGPoint(x: center.x + width / 2, y: center.y + height / 2)

        return [p1, p2, p3, p1]
    }

    func kochSnowflakePath(from points: [CGPoint], iterations: Int) -> Path {
        var path = Path()
        path.move(to: points[0])

        for i in 0 ..< points.count - 1 {
            drawKochLine(from: points[i], to: points[i + 1], depth: iterations, path: &path)
        }

        return path
    }

    func drawKochLine(from start: CGPoint, to end: CGPoint, depth: Int, path: inout Path) {
        if depth == 0 {
            path.addLine(to: end)
        } else {
            let dx = (end.x - start.x) / 3
            let dy = (end.y - start.y) / 3

            let p1 = CGPoint(x: start.x + dx, y: start.y + dy)
            let p2 = CGPoint(x: start.x + 2 * dx, y: start.y + 2 * dy)

            let midX = (start.x + end.x) / 2
            let midY = (start.y + end.y) / 2
            let peakX = midX + (dy * sqrt(3) / 2)
            let peakY = midY - (dx * sqrt(3) / 2)
            let peak = CGPoint(x: peakX, y: peakY)

            drawKochLine(from: start, to: p1, depth: depth - 1, path: &path)
            drawKochLine(from: p1, to: peak, depth: depth - 1, path: &path)
            drawKochLine(from: peak, to: p2, depth: depth - 1, path: &path)
            drawKochLine(from: p2, to: end, depth: depth - 1, path: &path)
        }
    }
}
