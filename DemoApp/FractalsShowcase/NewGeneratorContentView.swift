//
//  NewGeneratorContentView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import FractalGenerators
import SwiftUI

struct NewGeneratorContentView: View {
    @State private var selectedFractal: FractalTypeEnum = .mandelbrot

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with fractal selector
                HStack {
                    Text("Using Generators")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Picker("Select Fractal", selection: $selectedFractal) {
                        ForEach(FractalTypeEnum.allCases, id: \.self) { fractal in
                            Text(fractal.displayName).tag(fractal)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
                .padding()
                .background(Color(.systemGray))

                // Fractal display area
                VStack {
                    Text(selectedFractal.displayName)
                        .font(.headline)
                        .padding(.top)

                    // Display the selected fractal using the new generator architecture
                    selectedFractal.createView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Color(.systemRed))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Fractal Generator")
    }
}

#Preview {
    NewGeneratorContentView()
}
