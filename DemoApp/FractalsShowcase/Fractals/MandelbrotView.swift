//
//  MandelbrotView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import FractalGenerators
import SwiftUI

struct MandelbrotView: View {
    @State private var iterations: Int = 1000
    @State private var isLoading = false
    @State private var image: CGImage?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Generating Mandelbrot...")
            } else if let image = image {
                Image(image, scale: 1.0, label: Text("Mandelbrot"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Click Generate to start")
            }

            HStack {
                Text("Iterations: \(iterations)")
                Slider(value: Binding(
                    get: { Double(iterations) },
                    set: { iterations = Int($0) }
                ), in: 100 ... 5000, step: 100)
            }
            .padding()

            Button("Generate") {
                generateMandelbrot()
            }
            .disabled(isLoading)
        }
        .padding()
    }

    private func generateMandelbrot() {
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let mandelbrotRect = ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5))
            let width = 600
            let height = 600

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo.rawValue
            ) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            let data = context.data!.assumingMemoryBound(to: UInt8.self)

            for y in 0 ..< height {
                for x in 0 ..< width {
                    let complexPoint = viewCoordinatesToComplex(
                        x: Double(x),
                        y: Double(y),
                        rect: CGSize(width: width, height: height),
                        viewRect: mandelbrotRect
                    )
                    let iterationCount = computeMandelbrotIterations(
                        complexPoint,
                        maxIterations: iterations
                    )
                    let color = colorFromIteration(iterationCount, maxIterations: iterations)

                    let pixelIndex = (y * width + x) * 4
                    data[pixelIndex] = UInt8(color.red * 255) // R
                    data[pixelIndex + 1] = UInt8(color.green * 255) // G
                    data[pixelIndex + 2] = UInt8(color.blue * 255) // B
                    data[pixelIndex + 3] = UInt8(color.alpha * 255) // A
                }
            }

            let generatedImage = context.makeImage()

            DispatchQueue.main.async {
                self.image = generatedImage
                self.isLoading = false
            }
        }
    }

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

    private func colorFromIteration(_ iteration: Int, maxIterations: Int) -> (red: Double, green: Double, blue: Double, alpha: Double) {
        if iteration >= maxIterations {
            return (0, 0, 0, 1) // Black for points in the set
        }

        // Default color scheme using HSV
        let normalized = Double(iteration) / Double(maxIterations)
        let (r, g, b) = hsvToRgb(h: normalized, s: 1.0, v: 1.0)
        return (r, g, b, 1.0)
    }

    private func hsvToRgb(h: Double, s: Double, v: Double) -> (r: Double, g: Double, b: Double) {
        let c = v * s
        let x = c * (1 - abs((h * 6).truncatingRemainder(dividingBy: 2) - 1))
        let m = v - c

        let (r, g, b): (Double, Double, Double)
        switch Int(h * 6) % 6 {
        case 0: (r, g, b) = (c, x, 0)
        case 1: (r, g, b) = (x, c, 0)
        case 2: (r, g, b) = (0, c, x)
        case 3: (r, g, b) = (0, x, c)
        case 4: (r, g, b) = (x, 0, c)
        case 5: (r, g, b) = (c, 0, x)
        default: (r, g, b) = (0, 0, 0)
        }

        return (r + m, g + m, b + m)
    }
}

#Preview {
    MandelbrotView()
}
