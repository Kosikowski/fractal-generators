//
//  MangerSponge.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import Foundation
import SwiftUI

/**
 * Menger Sponge Fractal
 *
 * The Menger Sponge is a 3D fractal that is a 3D analogue of the Sierpinski Carpet.
 * In 2D projection, it appears as a fractal pattern created by recursively
 * removing the center square from a square and repeating on the remaining squares.
 *
 * Mathematical Foundation:
 * - Start with a square
 * - Divide it into 9 equal squares (3×3 grid)
 * - Remove the center square
 * - Repeat the process on each of the remaining 8 squares
 * - The process continues recursively to the desired depth
 *
 * Properties:
 * - Fractal dimension = log(8)/log(3) ≈ 1.893
 * - Self-similar at all scales
 * - Has zero area but infinite perimeter
 * - Demonstrates how simple rules create complex geometric patterns
 */

struct MengerSpongeView: View {
    let iterations: Int

    var body: some View {
        Canvas { context, size in
            let initialRect = CGRect(x: size.width * 0.1, y: size.height * 0.1, width: size.width * 0.8, height: size.height * 0.8)
            let path = mengerSpongePath(in: initialRect, iterations: iterations)

            context.fill(path, with: .color(.blue))
        }
        .background(Color.white)
    }

    func mengerSpongePath(in rect: CGRect, iterations: Int) -> Path {
        var path = Path()
        mengerSpongeRecursive(in: rect, depth: iterations, path: &path)
        return path
    }

    func mengerSpongeRecursive(in rect: CGRect, depth: Int, path: inout Path) {
        if depth == 0 {
            path.addRect(rect)
        } else {
            let w = rect.width / 3
            let h = rect.height / 3

            for row in 0 ..< 3 {
                for col in 0 ..< 3 {
                    if row == 1 && col == 1 {
                        continue // Remove center square
                    }
                    let newRect = CGRect(
                        x: rect.origin.x + CGFloat(col) * w,
                        y: rect.origin.y + CGFloat(row) * h,
                        width: w,
                        height: h
                    )
                    mengerSpongeRecursive(in: newRect, depth: depth - 1, path: &path)
                }
            }
        }
    }
}
