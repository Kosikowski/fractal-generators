//
//  ContentView.swift
//  Mandelbrot
//
//  Created by Mateusz Kosikowski 2021.
//

import AppKit
import ComplexModule
import SwiftUI

struct ContentView: View {
    enum FractalType: String, CaseIterable, Identifiable {
        case mandelbrot, kochSnowflake, sierpinskiTriangle, sierpinskiCarpet, mengerSponge, juliaSet, mandelbrotSet, brownianMotion, burningShip, plasma, perlinNoise, barnsleyFern, dragonCurve, lorenzAttractor, henonAttractor, snowflake, treeBranching, coastlineMountain, pythagoreanTree, apollonianGasket, boxCounting, romanescoBroccoli, riverNetwork, lightningPattern, logisticMap, chuaCircuit, rosslerAttractor, levyCCurve, heighwayDragon, sierpinskiArrowhead, diamondSquare, levyFlight, fbm

        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .mandelbrot: return "Mandelbrot"
            case .kochSnowflake: return "Koch Snowflake"
            case .sierpinskiTriangle: return "Sierpinski Triangle"
            case .sierpinskiCarpet: return "Sierpinski Carpet"
            case .mengerSponge: return "Menger Sponge"
            case .juliaSet: return "Julia Set"
            case .mandelbrotSet: return "Mandelbrot Set"
            case .brownianMotion: return "Brownian Motion"
            case .burningShip: return "Burning Ship Fractal"
            case .plasma: return "Plasma Fractal"
            case .perlinNoise: return "Perlin Noise"
            case .barnsleyFern: return "Barnsley Fern"
            case .dragonCurve: return "Dragon Curve"
            case .lorenzAttractor: return "Lorenz Attractor"
            case .henonAttractor: return "Henon Attractor"
            case .snowflake: return "Snowflake"
            case .treeBranching: return "Tree Branching"
            case .coastlineMountain: return "Coastline Mountain"
            case .pythagoreanTree: return "Pythagorean Tree"
            case .apollonianGasket: return "Apollonian Gasket"
            case .boxCounting: return "Box Counting"
            case .romanescoBroccoli: return "Romanesco Broccoli"
            case .riverNetwork: return "River Network"
            case .lightningPattern: return "Lightning Pattern"
            case .logisticMap: return "Logistic Map"
            case .chuaCircuit: return "Chua Circuit"
            case .rosslerAttractor: return "Rossler Attractor"
            case .levyCCurve: return "Levy C Curve"
            case .heighwayDragon: return "Heighway Dragon"
            case .sierpinskiArrowhead: return "Sierpinski Arrowhead"
            case .diamondSquare: return "Diamond Square"
            case .levyFlight: return "Levy Flight"
            case .fbm: return "Fractional Brownian Motion"
            }
        }
    }

    @State private var selected: FractalType?

    var body: some View {
        NavigationStack {
            List(FractalType.allCases) { fractal in
                NavigationLink(fractal.displayName, value: fractal)
            }
            .navigationTitle("Fractals")
            .navigationDestination(for: FractalType.self) { fractal in
                FractalDetailView(fractal: fractal)
            }
        }
    }
}

struct FractalDetailView: View {
    let fractal: ContentView.FractalType
    var body: some View {
        switch fractal {
        case .mandelbrot:
            MandelbrotView()
        case .kochSnowflake:
            KochSnowflakeView(iterations: 5)
        case .sierpinskiTriangle:
            SierpinskiTriangleView(iterations: 15)
        case .sierpinskiCarpet:
            SierpinskiCarpetView(iterations: 6)
        case .mengerSponge:
            MengerSpongeView(iterations: 2)
        case .juliaSet:
            JuliaSetView(iterations: 100)
        case .mandelbrotSet:
            MandelbrotSetView(iterations: 100)
        case .brownianMotion:
            BrownianMotionView(steps: 100)
        case .burningShip:
            BurningShipFractalView(iterations: 100)
        case .plasma:
            PlasmaFractalView(size: 10, roughness: 0.5)
        case .perlinNoise:
            PerlinNoiseView(width: 512, height: 512, scale: 56.0)
        case .barnsleyFern:
            BarnsleyFernView(iterations: 1_000_000)
        case .dragonCurve:
            DragonCurveView(iterations: 15)
        case .lorenzAttractor:
            LorenzAttractorView(iterations: 100_000)
        case .henonAttractor:
            HenonAttractorView(iterations: 1_000_000)
        case .snowflake:
            SnowflakeView(iterations: 10)
        case .treeBranching:
            TreeBranchingView(iterations: 15)
        case .coastlineMountain:
            CoastlineMountainView(iterations: 18, roughness: 0.7)
        case .pythagoreanTree:
            PythagoreanTreeView(iterations: 8, angle: .pi / 4, scale: 0.707)
        case .apollonianGasket:
            ApollonianGasketView(iterations: 4)
        case .boxCounting:
            BoxCountingView(fractalIterations: 4, boxLevels: 5)
        case .romanescoBroccoli:
            RomanescoBroccoliView(iterations: 4)
        case .riverNetwork:
            RiverNetworkView(iterations: 40)
        case .lightningPattern:
            LightningPatternView(iterations: 25)
        case .logisticMap:
            LogisticMapView(iterations: 300)
        case .chuaCircuit:
            ChuaCircuitView(iterations: 20000)
        case .rosslerAttractor:
            RosslerAttractorView(iterations: 20000)
        case .levyCCurve:
            LevyCCurveView(iterations: 8)
        case .heighwayDragon:
            HeighwayDragonView(iterations: 18)
        case .sierpinskiArrowhead:
            SierpinskiArrowheadView(iterations: 12)
        case .diamondSquare:
            DiamondSquareView(iterations: 8)
        case .levyFlight:
            LevyFlightView(steps: 1000)
        case .fbm:
            FBMView(octaves: 10, hurst: 0.8)
        }
    }
}

#Preview {
    ContentView()
}
