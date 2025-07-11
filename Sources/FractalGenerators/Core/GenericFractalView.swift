//
//  GenericFractalView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Generic view that can display any type of fractal
struct GenericFractalView<Generator: FractalGenerator>: View {
    let generator: Generator
    let parameters: Generator.Parameters
    @State private var image: CGImage?
    @State private var path: Path?
    @State private var points: [CGPoint] = []
    @State private var isLoading = true
    @State private var progress: Double = 0.0

    init(generator: Generator, parameters: Generator.Parameters) {
        self.generator = generator
        self.parameters = parameters
    }

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView("Generating fractal...")
                    if progress > 0 {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle())
                    }
                }
            } else {
                displayContent
            }
        }
        .onAppear {
            generateFractal()
        }
    }

    @ViewBuilder
    private var displayContent: some View {
        if let image = image {
            Image(image, scale: 1.0, label: Text("Fractal"))
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let path = path {
            Canvas { context, _ in
                context.stroke(path, with: .color(.blue), lineWidth: 2)
            }
            .background(Color.white)
        } else if !points.isEmpty {
            Canvas { context, size in
                drawPoints(points: points, context: context, size: size)
            }
        } else {
            Text("Failed to generate fractal")
                .foregroundColor(.red)
        }
    }

    /// Default generic fallback fractal generation
    func generateFractal() {
        isLoading = true
        progress = 0.0

        let generator = self.generator
        let parameters = self.parameters

        generator.generateAsync(with: parameters) { progress in
            DispatchQueue.main.async {
                self.progress = progress
            }
        } completion: { output in
            DispatchQueue.main.async {
                self.handleOutput(output)
                self.isLoading = false
            }
        }
    }

    private func handleOutput(_ output: Generator.Output) {
        // This is a fallback for generators that don't conform to specific protocols
        // In practice, most generators should conform to one of the specific protocols
        if let path = output as? Path {
            self.path = path
        } else if let points = output as? [CGPoint] {
            self.points = points
        } else if output is CGImage {
            image = output as! CGImage
        }
    }

    private func drawPoints(points: [CGPoint], context: GraphicsContext, size _: CGSize) {
        for point in points {
            let rect = CGRect(x: point.x - 1, y: point.y - 1, width: 2, height: 2)
            context.fill(Path(rect), with: .color(.blue))
        }
    }
}

// MARK: - Convenience Extensions

extension GenericFractalView where Generator: ImageFractalGenerator {
    func generateFractal() {
        isLoading = true
        let generator = self.generator
        let parameters = self.parameters

        DispatchQueue.global(qos: .userInitiated).async {
            let image = generator.generateImage(with: parameters)
            DispatchQueue.main.async {
                self.image = image
                self.isLoading = false
            }
        }
    }
}

extension GenericFractalView where Generator: PathFractalGenerator {
    func generateFractal() {
        isLoading = true
        let generator = self.generator
        let parameters = self.parameters

        DispatchQueue.global(qos: .userInitiated).async {
            let path = generator.generatePath(with: parameters)
            DispatchQueue.main.async {
                self.path = path
                self.isLoading = false
            }
        }
    }
}

extension GenericFractalView where Generator: PointFractalGenerator {
    func generateFractal() {
        isLoading = true
        let generator = self.generator
        let parameters = self.parameters

        DispatchQueue.global(qos: .userInitiated).async {
            let points = generator.generatePoints(with: parameters)
            DispatchQueue.main.async {
                self.points = points
                self.isLoading = false
            }
        }
    }
}

extension GenericFractalView where Generator: ProgressiveFractalGenerator {
    func generateFractal() {
        isLoading = true
        progress = 0.0
        let generator = self.generator
        let parameters = self.parameters

        generator.generateProgressive(with: parameters) { image, progress in
            DispatchQueue.main.async {
                self.image = image
                self.progress = progress
                if progress >= 1.0 {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview Support

struct GenericFractalView_Previews: PreviewProvider {
    static var previews: some View {
        // This would need actual generator implementations to work
        Text("Generic Fractal View Preview")
    }
}
