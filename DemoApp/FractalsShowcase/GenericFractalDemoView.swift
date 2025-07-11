//
//  GenericFractalDemoView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import FractalGenerators
import SwiftUI

/// Demonstration view showing the new generic fractal architecture
struct GenericFractalDemoView: View {
    @State private var selectedFractal: DemoFractalType = .mandelbrot
    @State private var iterations: Double = 1000
    @State private var depth: Double = 6
    @State private var size: CGSize = .init(width: 400, height: 400)

    var body: some View {
        VStack(spacing: 20) {
            Text("Generic Fractal Architecture Demo")
                .font(.title)
                .padding()

            // Fractal type picker
            Picker("Fractal Type", selection: $selectedFractal) {
                ForEach(DemoFractalType.allCases, id: \.self) { fractal in
                    Text(fractal.displayName).tag(fractal)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            // Parameter controls
            VStack(alignment: .leading, spacing: 10) {
                Text("Parameters:")
                    .font(.headline)

                HStack {
                    Text("Iterations:")
                    Slider(value: $iterations, in: 100 ... 5000, step: 100)
                    Text("\(Int(iterations))")
                }

                if selectedFractal == .sierpinskiTriangle {
                    HStack {
                        Text("Depth:")
                        Slider(value: $depth, in: 1 ... 10, step: 1)
                        Text("\(Int(depth))")
                    }
                }
            }
            .padding()

            // Fractal display
            fractalView
                .frame(width: size.width, height: size.height)
                .border(Color.gray, width: 1)

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private var fractalView: some View {
        switch selectedFractal {
        case .mandelbrot:
            mandelbrotView
        case .sierpinskiTriangle:
            sierpinskiView
        case .lorenzAttractor:
            lorenzView
        }
    }

    private var mandelbrotView: some View {
        // Direct implementation for demonstration
        Canvas { context, size in
            drawMandelbrot(context: context, size: size)
        }
    }

    private var sierpinskiView: some View {
        // Direct implementation for demonstration
        Canvas { context, size in
            let path = generateSierpinskiPath(size: size, depth: Int(depth))
            context.stroke(path, with: .color(.blue), lineWidth: 2)
        }
        .background(Color.white)
    }

    private var lorenzView: some View {
        // Direct implementation for demonstration
        Canvas { context, size in
            let points = generateLorenzPoints(size: size, iterations: Int(iterations))
            for point in points {
                let rect = CGRect(x: point.x - 1, y: point.y - 1, width: 2, height: 2)
                context.fill(Path(rect), with: .color(.blue))
            }
        }
    }

    // MARK: - Direct Implementations for Demo

    private func drawMandelbrot(context: GraphicsContext, size: CGSize) {
        let viewRect = ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5))
        let width = Int(size.width)
        let height = Int(size.height)

        for y in 0 ..< height {
            for x in 0 ..< width {
                let complexPoint = viewCoordinatesToComplex(
                    x: Double(x),
                    y: Double(y),
                    rect: size,
                    viewRect: viewRect
                )
                let iterationCount = computeMandelbrotIterations(
                    complexPoint,
                    maxIterations: Int(iterations)
                )
                let color = colorFromIteration(iterationCount, maxIterations: Int(iterations))

                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(color))
            }
        }
    }

    private func generateSierpinskiPath(size: CGSize, depth: Int) -> Path {
        let initialTriangle = initialTriangle(in: size)
        return sierpinskiTrianglePath(from: initialTriangle, depth: depth)
    }

    private func generateLorenzPoints(size: CGSize, iterations: Int) -> [CGPoint] {
        var points: [CGPoint] = []

        let sigma = 10.0
        let rho = 28.0
        let beta = 8.0 / 3.0
        let dt = 0.01
        let scale = 15.0

        var x = 0.1
        var y = 0.0
        var z = 0.0

        let offsetX = size.width / 2
        let offsetY = size.height / 2

        for _ in 0 ..< iterations {
            let dx = sigma * (y - x)
            let dy = x * (rho - z) - y
            let dz = x * y - beta * z

            x += dx * dt
            y += dy * dt
            z += dz * dt

            let px = x * scale + offsetX
            let py = z * scale + offsetY

            if px >= 0 && px < size.width && py >= 0 && py < size.height {
                points.append(CGPoint(x: px, y: py))
            }
        }

        return points
    }

    // MARK: - Helper Methods

    private func viewCoordinatesToComplex(x: Double, y: Double, rect: CGSize, viewRect: ComplexRect) -> Complex<Double> {
        let tl = viewRect.topLeft
        let br = viewRect.bottomRight
        let real = tl.real + (x / rect.width) * (br.real - tl.real)
        let imaginary = tl.imaginary + (y / rect.height) * (br.imaginary - tl.imaginary)
        return Complex(real, imaginary)
    }

    private func computeMandelbrotIterations(_ c: Complex<Double>, maxIterations: Int) -> Int {
        var z = Complex<Double>(0.0, 0.0)
        for iteration in 0 ..< maxIterations {
            z = z * z + c
            if z.length > 2 {
                return iteration
            }
        }
        return maxIterations
    }

    private func colorFromIteration(_ iteration: Int, maxIterations: Int) -> Color {
        if iteration >= maxIterations {
            return .black
        }

        let normalized = Double(iteration) / Double(maxIterations)
        return Color(hue: normalized, saturation: 1.0, brightness: 1.0)
    }

    private func initialTriangle(in size: CGSize) -> [CGPoint] {
        let width = min(size.width, size.height) * 0.8
        let height = width * sqrt(3) / 2
        let center = CGPoint(x: size.width / 2, y: size.height / 2 + height / 4)

        let p1 = CGPoint(x: center.x, y: center.y - height / 2)
        let p2 = CGPoint(x: center.x - width / 2, y: center.y + height / 2)
        let p3 = CGPoint(x: center.x + width / 2, y: center.y + height / 2)

        return [p1, p2, p3]
    }

    private func sierpinskiTrianglePath(from points: [CGPoint], depth: Int) -> Path {
        var path = Path()
        sierpinskiRecursive(from: points, depth: depth, path: &path)
        return path
    }

    private func sierpinskiRecursive(from points: [CGPoint], depth: Int, path: inout Path) {
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

    private func midpoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
}

// MARK: - Fractal Type Enum

enum DemoFractalType: String, CaseIterable {
    case mandelbrot = "Mandelbrot"
    case sierpinskiTriangle = "Sierpinski Triangle"
    case lorenzAttractor = "Lorenz Attractor"

    var displayName: String {
        return rawValue
    }
}

#Preview {
    GenericFractalDemoView()
}
