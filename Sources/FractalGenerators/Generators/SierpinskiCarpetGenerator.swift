//
//  SierpinskiCarpetGenerator.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Sierpinski Carpet Fractal Generator
struct SierpinskiCarpetGenerator: PathFractalGenerator {
    func generate(with parameters: RecursiveFractalParameters) -> Path {
        let initialRect = CGRect(x: parameters.size.width * 0.1, y: parameters.size.height * 0.1, width: parameters.size.width * 0.8, height: parameters.size.height * 0.8)
        return sierpinskiCarpetPath(in: initialRect, depth: parameters.depth)
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

    private func sierpinskiCarpetPath(in rect: CGRect, depth: Int) -> Path {
        var path = Path()
        sierpinskiCarpetRecursive(in: rect, depth: depth, path: &path)
        return path
    }

    private func sierpinskiCarpetRecursive(in rect: CGRect, depth: Int, path: inout Path) {
        if depth == 0 {
            path.addRect(rect)
        } else {
            let w = rect.width / 3
            let h = rect.height / 3
            for row in 0 ..< 3 {
                for col in 0 ..< 3 {
                    if row == 1 && col == 1 {
                        continue // Skip center square
                    }
                    let newRect = CGRect(
                        x: rect.origin.x + CGFloat(col) * w,
                        y: rect.origin.y + CGFloat(row) * h,
                        width: w,
                        height: h
                    )
                    sierpinskiCarpetRecursive(in: newRect, depth: depth - 1, path: &path)
                }
            }
        }
    }
}
