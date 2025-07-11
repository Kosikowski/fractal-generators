//
//  SimpleArchitectureDemo.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import SwiftUI

/// Simple demonstration of the new generic fractal architecture
struct SimpleArchitectureDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Generic Fractal Architecture Demo")
                .font(.title)
                .padding()

            Text("This demonstrates the new generic architecture:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                Text("✅ Protocol-based design")
                Text("✅ Type-safe parameters")
                Text("✅ Reusable generators")
                Text("✅ Generic view system")
                Text("✅ Progressive rendering support")
            }
            .padding()

            // Show the factory in action
            VStack {
                Text("Factory Examples:")
                    .font(.headline)

                // These would use the actual factory methods
                Text("• Mandelbrot: Complex plane fractal")
                Text("• Sierpinski: Recursive geometric fractal")
                Text("• Lorenz: Chaotic attractor")
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SimpleArchitectureDemo()
}
