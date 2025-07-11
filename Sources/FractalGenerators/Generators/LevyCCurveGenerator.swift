//
//  LevyCCurveGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Levy C Curve Fractal Generator
struct LevyCCurveGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        let width = Double(parameters.size.width)
        let height = Double(parameters.size.height)
        let initialLength = width * 0.7 * pow(0.8, Double(parameters.depth))
        let startX = width / 2 - initialLength / 2
        let startY = height / 2
        var path = Path()
        drawLevyC(path: &path, x: startX, y: startY, length: initialLength, angle: 0, depth: parameters.depth)
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

    private func drawLevyC(path: inout Path, x: Double, y: Double, length: Double, angle: Double, depth: Int) {
        if depth <= 0 {
            let endX = x + cos(angle) * length
            let endY = y + sin(angle) * length
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: endX, y: endY))
            return
        }
        let newLength = length * (sqrt(2) / 2)
        let angle1 = angle + .pi / 4
        let midX = x + cos(angle1) * newLength
        let midY = y + sin(angle1) * newLength
        drawLevyC(path: &path, x: x, y: y, length: newLength, angle: angle1, depth: depth - 1)
        let angle2 = angle1 - .pi / 2
        drawLevyC(path: &path, x: midX, y: midY, length: newLength, angle: angle2, depth: depth - 1)
    }
}
