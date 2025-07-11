//
//  PythagoreanTreeGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Pythagorean Tree Fractal Generator
struct PythagoreanTreeGenerator: PathFractalGenerator {
    let angle: Double // Angle of branching (radians)
    let scale: Double // Scaling factor for child squares

    func generate(with parameters: RecursiveFractalParameters) -> Path {
        let width = Double(parameters.size.width)
        let height = Double(parameters.size.height)
        let initialSize = height * 0.2
        let startX = width / 2 - initialSize / 2
        let startY = height - initialSize
        var path = Path()
        drawSquare(path: &path, x: startX, y: startY, size: initialSize, angle: 0, depth: parameters.depth)
        return path
    }

    func generatePath(with parameters: RecursiveFractalParameters) -> Path {
        return generate(with: parameters)
    }

    func generateAsync(with parameters: RecursiveFractalParameters, progress _: @escaping (Double) -> Void, completion: @escaping (Path) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let path = self.generate(with: parameters)
            DispatchQueue.main.async {
                completion(path)
            }
        }
    }

    private func drawSquare(path: inout Path, x: Double, y: Double, size: Double, angle: Double, depth: Int) {
        if depth <= 0 {
            return
        }
        let points = [
            CGPoint(x: x, y: y),
            CGPoint(x: x + size, y: y),
            CGPoint(x: x + size, y: y + size),
            CGPoint(x: x, y: y + size),
        ]
        var rotatedPoints = [CGPoint]()
        for point in points {
            let dx = point.x - x
            let dy = point.y - y
            let newX = x + dx * cos(angle) - dy * sin(angle)
            let newY = y + dx * sin(angle) + dy * cos(angle)
            rotatedPoints.append(CGPoint(x: newX, y: newY))
        }
        path.move(to: rotatedPoints[0])
        for i in 1 ..< 4 {
            path.addLine(to: rotatedPoints[i])
        }
        path.addLine(to: rotatedPoints[0])
        path.closeSubpath()
        let topLeft = rotatedPoints[3]
        let topRight = rotatedPoints[2]
        let newSize = size * scale
        let leftAngle = angle + .pi / 2 - self.angle
        drawSquare(path: &path, x: topLeft.x, y: topLeft.y, size: newSize, angle: leftAngle, depth: depth - 1)
        let rightAngle = angle + .pi / 2 + self.angle
        let rightBaseX = topRight.x - newSize * cos(rightAngle)
        let rightBaseY = topRight.y - newSize * sin(rightAngle)
        drawSquare(path: &path, x: rightBaseX, y: rightBaseY, size: newSize, angle: rightAngle, depth: depth - 1)
    }
}
