//
//  SierpinskiTriangle.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import Foundation
import SwiftUI

/**
 * Sierpinski Triangle Fractal
 *
 * The Sierpinski Triangle is a fractal created by recursively subdividing
 * a triangle and removing the central triangle at each step.
 *
 * Mathematical Foundation:
 * - Start with an equilateral triangle
 * - Find the midpoints of each side
 * - Connect the midpoints to form 4 smaller triangles
 * - Remove the center triangle
 * - Repeat the process on the remaining 3 triangles
 * - Continue recursively to the desired depth
 *
 * Properties:
 * - Fractal dimension = log(3)/log(2) ≈ 1.585
 * - Self-similar at all scales
 * - Has zero area but infinite perimeter
 * - One of the most famous and fundamental fractals
 */

struct SierpinskiTriangleView: View {
    let iterations: Int

    var body: some View {
        Canvas { context, size in
            let initialTriangle = initialTriangle(in: size)
            let path = sierpinskiTrianglePath(from: initialTriangle, iterations: iterations)

            context.stroke(path, with: .color(.blue), lineWidth: 2)
        }
        .background(Color.white)
    }

    func initialTriangle(in size: CGSize) -> [CGPoint] {
        let width = min(size.width, size.height) * 0.8
        let height = width * sqrt(3) / 2
        let center = CGPoint(x: size.width / 2, y: size.height / 2 + height / 4)

        let p1 = CGPoint(x: center.x, y: center.y - height / 2)
        let p2 = CGPoint(x: center.x - width / 2, y: center.y + height / 2)
        let p3 = CGPoint(x: center.x + width / 2, y: center.y + height / 2)

        return [p1, p2, p3]
    }

    func sierpinskiTrianglePath(from points: [CGPoint], iterations: Int) -> Path {
        var path = Path()
        sierpinskiRecursive(from: points, depth: iterations, path: &path)
        return path
    }

    func sierpinskiRecursive(from points: [CGPoint], depth: Int, path: inout Path) {
        if depth == 0 {
            path.move(to: points[0])
            path.addLine(to: points[1])
            path.addLine(to: points[2])
            path.addLine(to: points[0])
        } else {
            let mid1 = midpoint(points[0], points[1])
            let mid2 = midpoint(points[1], points[2])
            let mid3 = midpoint(points[2], points[0])

            sierpinskiRecursive(from: [points[0], mid1, mid3], depth: depth - 1, path: &path)
            sierpinskiRecursive(from: [mid1, points[1], mid2], depth: depth - 1, path: &path)
            sierpinskiRecursive(from: [mid3, mid2, points[2]], depth: depth - 1, path: &path)
        }
    }

    func midpoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
}
