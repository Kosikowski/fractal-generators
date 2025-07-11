//
//  FractalFactory.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import ComplexModule
import CoreGraphics
import Foundation
import SwiftUI

/// Factory for creating parameterized fractals
enum FractalFactory {
    // MARK: - Mandelbrot Fractal

    static func createMandelbrot(
        iterations: Int = 1000,
        viewRect: ComplexRect = ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5)),
        blockiness: Double = 0.5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<MandelbrotGenerator> {
        let generator = MandelbrotGenerator()
        let parameters = ComplexPlaneParameters(
            iterations: iterations,
            size: size,
            viewRect: viewRect,
            blockiness: blockiness
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Sierpinski Triangle Fractal

    static func createSierpinski(
        depth: Int = 6,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<SierpinskiTriangleGenerator> {
        let generator = SierpinskiTriangleGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Lorenz Attractor Fractal

    static func createLorenz(
        iterations: Int = 10000,
        dt: Double = 0.01,
        initialConditions: [Double] = [0.1, 0.0, 0.0],
        scale: Double = 15.0,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<LorenzAttractorGenerator> {
        let generator = LorenzAttractorGenerator()
        let parameters = AttractorParameters(
            iterations: iterations,
            size: size,
            dt: dt,
            initialConditions: initialConditions,
            scale: scale
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Julia Set Fractal

    static func createJulia(
        iterations: Int = 1000,
        c _: Complex<Double> = Complex(-0.7, 0.27015),
        viewRect: ComplexRect = ComplexRect(Complex(-2.0, 2.0), Complex(2.0, -2.0)),
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<JuliaSetGenerator> {
        let generator = JuliaSetGenerator()
        let parameters = ComplexPlaneParameters(
            iterations: iterations,
            size: size,
            viewRect: viewRect,
            blockiness: 0.5
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Koch Snowflake Fractal

    static func createKochSnowflake(
        iterations: Int = 4,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<KochSnowflakeGenerator> {
        let generator = KochSnowflakeGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: iterations,
            size: size,
            depth: iterations
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Dragon Curve Fractal

    static func createDragonCurve(
        iterations: Int = 12,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<DragonCurveGenerator> {
        let generator = DragonCurveGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: iterations,
            size: size,
            depth: iterations
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Barnsley Fern Fractal

    static func createBarnsleyFern(
        iterations _: Int = 50000,
        size _: CGSize = CGSize(width: 500, height: 600)
    ) -> AnyView {
        // TODO: Implement BarnsleyFernGenerator
        return AnyView(Text("Barnsley Fern - Not implemented yet"))
    }

    // MARK: - Burning Ship Fractal

    static func createBurningShip(
        iterations: Int = 1000,
        viewRect: ComplexRect = ComplexRect(Complex(-2.0, 1.5), Complex(1.5, -2.0)),
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<BurningShipGenerator> {
        let generator = BurningShipGenerator()
        let parameters = ComplexPlaneParameters(
            iterations: iterations,
            size: size,
            viewRect: viewRect,
            blockiness: 0.5
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Sierpinski Carpet Fractal

    static func createSierpinskiCarpet(
        depth: Int = 5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<SierpinskiCarpetGenerator> {
        let generator = SierpinskiCarpetGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Henon Attractor Fractal

    static func createHenonAttractor(
        iterations: Int = 10000,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<HenonAttractorGenerator> {
        let generator = HenonAttractorGenerator()
        let parameters = AttractorParameters(
            iterations: iterations,
            size: size
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Rossler Attractor Fractal

    static func createRosslerAttractor(
        iterations: Int = 10000,
        dt: Double = 0.02,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<RosslerAttractorGenerator> {
        let generator = RosslerAttractorGenerator()
        let parameters = AttractorParameters(
            iterations: iterations,
            size: size,
            dt: dt
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Pythagorean Tree Fractal

    static func createPythagoreanTree(
        depth: Int = 8,
        angle: Double = .pi / 6,
        scale: Double = sqrt(2) / 2,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<PythagoreanTreeGenerator> {
        let generator = PythagoreanTreeGenerator(angle: angle, scale: scale)
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Box Counting Fractal

    static func createBoxCounting(
        depth: Int = 4,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<BoxCountingGenerator> {
        let generator = BoxCountingGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Levy C Curve Fractal

    static func createLevyCCurve(
        depth: Int = 12,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<LevyCCurveGenerator> {
        let generator = LevyCCurveGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Brownian Motion Fractal

    static func createBrownianMotion(
        steps: Int = 1000,
        stepSize: CGFloat = 5.0,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<BrownianMotionGenerator> {
        let generator = BrownianMotionGenerator(stepSize: stepSize)
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: steps
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Diamond-Square Fractal

    static func createDiamondSquare(
        depth: Int = 6,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<DiamondSquareGenerator> {
        let generator = DiamondSquareGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Apollonian Gasket Fractal

    static func createApollonianGasket(
        depth: Int = 6,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<ApollonianGasketGenerator> {
        let generator = ApollonianGasketGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Coastline Fractal

    static func createCoastline(
        iterations: Int = 8,
        roughness: Double = 0.5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<CoastlineGenerator> {
        let generator = CoastlineGenerator()
        let parameters = CoastlineParameters(
            iterations: iterations,
            size: size,
            roughness: roughness
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - FBM Fractal

    static func createFBM(
        octaves: Int = 6,
        hurst: Double = 0.5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<FBMGenerator> {
        let generator = FBMGenerator()
        let parameters = FBMParameters(
            iterations: 1000,
            size: size,
            octaves: octaves,
            hurst: hurst
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Heighway Dragon Fractal

    static func createHeighwayDragon(
        depth: Int = 12,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<HeighwayDragonGenerator> {
        let generator = HeighwayDragonGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Chua Circuit Fractal

    static func createChuaCircuit(
        iterations: Int = 10000,
        dt: Double = 0.02,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<ChuaCircuitGenerator> {
        let generator = ChuaCircuitGenerator()
        let parameters = ChuaCircuitParameters(
            iterations: iterations,
            size: size,
            dt: dt
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Tree Branching Fractal

    static func createTreeBranching(
        depth: Int = 8,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<TreeBranchingGenerator> {
        let generator = TreeBranchingGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Snow Flake Fractal

    static func createSnowFlake(
        depth: Int = 4,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<SnowFlakeGenerator> {
        let generator = SnowFlakeGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Sierpinski Arrowhead Fractal

    static func createSierpinskiArrowhead(
        depth: Int = 6,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<SierpinskiArrowheadGenerator> {
        let generator = SierpinskiArrowheadGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Romanesco Broccoli Fractal

    static func createRomanescoBroccoli(
        depth: Int = 5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<RomanescoBroccoliGenerator> {
        let generator = RomanescoBroccoliGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - River Network Fractal

    static func createRiverNetwork(
        depth: Int = 6,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<RiverNetworkGenerator> {
        let generator = RiverNetworkGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Plasma Fractal

    static func createPlasmaFractal(
        roughness: Double = 0.5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<PlasmaFractalGenerator> {
        let generator = PlasmaFractalGenerator()
        let parameters = PlasmaFractalParameters(
            iterations: 1000,
            size: size,
            roughness: roughness
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Perlin Noise Fractal

    static func createPerlinNoise(
        scale: Double = 50.0,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<PerlinNoiseGenerator> {
        let generator = PerlinNoiseGenerator()
        let parameters = PerlinNoiseParameters(
            iterations: 1000,
            size: size,
            scale: scale
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Logistic Map Fractal

    static func createLogisticMap(
        iterations: Int = 1000,
        rMin: Double = 2.5,
        rMax: Double = 4.0,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<LogisticMapGenerator> {
        let generator = LogisticMapGenerator()
        let parameters = LogisticMapParameters(
            iterations: iterations,
            size: size,
            rMin: rMin,
            rMax: rMax
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Lightning Pattern Fractal

    static func createLightningPattern(
        depth: Int = 8,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<LightningPatternGenerator> {
        let generator = LightningPatternGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Levy Flight Fractal

    static func createLevyFlight(
        iterations: Int = 1000,
        alpha: Double = 1.5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<LevyFlightGenerator> {
        let generator = LevyFlightGenerator()
        let parameters = LevyFlightParameters(
            iterations: iterations,
            size: size,
            alpha: alpha,
            minStep: 1.0,
            maxStep: 180.0
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Manger Sponge Fractal

    static func createMangerSponge(
        depth: Int = 4,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<MangerSpongeGenerator> {
        let generator = MangerSpongeGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Mandelbrot2 Fractal

    static func createMandelbrot2(
        iterations: Int = 100,
        zoom: Double = 1.5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<Mandelbrot2Generator> {
        let generator = Mandelbrot2Generator()
        let parameters = Mandelbrot2Parameters(
            iterations: iterations,
            size: size,
            zoom: zoom
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Tricorn Fractal

    static func createTricorn(
        iterations: Int = 1000,
        viewRect: ComplexRect = ComplexRect(Complex(-2.0, 1.5), Complex(2.0, -1.5)),
        blockiness: Double = 0.5,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<TricornFractalGenerator> {
        let generator = TricornFractalGenerator()
        let parameters = TricornFractalParameters(
            iterations: iterations,
            size: size,
            viewRect: viewRect,
            blockiness: blockiness
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Hilbert Curve Fractal

    static func createHilbertCurve(
        depth: Int = 6,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<HilbertCurveGenerator> {
        let generator = HilbertCurveGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Cantor Set Fractal

    static func createCantorSet(
        depth: Int = 8,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<CantorSetGenerator> {
        let generator = CantorSetGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 1000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Newton Fractal

    static func createNewton(
        iterations: Int = 100,
        viewRect: ComplexRect = ComplexRect(Complex(-2.0, 2.0), Complex(2.0, -2.0)),
        tolerance: Double = 1e-6,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<NewtonFractalGenerator> {
        let generator = NewtonFractalGenerator()
        let parameters = NewtonFractalParameters(
            iterations: iterations,
            size: size,
            viewRect: viewRect,
            tolerance: tolerance
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Buddhabrot Fractal

    static func createBuddhabrot(
        iterations: Int = 1000,
        viewRect: ComplexRect = ComplexRect(Complex(-2.0, 2.0), Complex(2.0, -2.0)),
        samples: Int = 100_000,
        maxIterations: Int = 100,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<BuddhabrotGenerator> {
        let generator = BuddhabrotGenerator()
        let parameters = BuddhabrotParameters(
            iterations: iterations,
            size: size,
            viewRect: viewRect,
            samples: samples,
            maxIterations: maxIterations
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Peano Curve Fractal

    static func createPeanoCurve(
        depth: Int = 3,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<PeanoCurveGenerator> {
        let generator = PeanoCurveGenerator()
        let parameters = PeanoCurveParameters(
            depth: depth,
            size: size
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Gosper Curve Fractal

    static func createGosperCurve(
        depth: Int = 4,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<GosperCurveGenerator> {
        let generator = GosperCurveGenerator()
        let parameters = GosperCurveParameters(
            depth: depth,
            size: size
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Clifford Attractor Fractal

    static func createCliffordAttractor(
        iterations: Int = 100_000,
        a: Double = -1.4,
        b: Double = 1.6,
        c: Double = 1.0,
        d: Double = 0.7,
        initial: CGPoint = CGPoint(x: 0, y: 0),
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<CliffordAttractorGenerator> {
        let generator = CliffordAttractorGenerator()
        let parameters = CliffordAttractorParameters(
            iterations: iterations,
            size: size,
            a: a,
            b: b,
            c: c,
            d: d,
            initial: initial
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - De Jong Attractor Fractal

    static func createDeJongAttractor(
        iterations: Int = 100_000,
        a: Double = 2.01,
        b: Double = -2.53,
        c: Double = 1.61,
        d: Double = -0.33,
        initial: CGPoint = CGPoint(x: 0, y: 0),
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<DeJongAttractorGenerator> {
        let generator = DeJongAttractorGenerator()
        let parameters = DeJongAttractorParameters(
            iterations: iterations,
            size: size,
            a: a,
            b: b,
            c: c,
            d: d,
            initial: initial
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Gingerbreadman Map Fractal

    static func createGingerbreadmanMap(
        iterations: Int = 100_000,
        initial: CGPoint = CGPoint(x: 0.1, y: 0.1),
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<GingerbreadmanMapGenerator> {
        let generator = GingerbreadmanMapGenerator()
        let parameters = GingerbreadmanMapParameters(
            iterations: iterations,
            size: size,
            initial: initial
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Conway's Game of Life Fractal

    static func createConwaysGameOfLife(
        gridSize: Int = 100,
        initialDensity: Double = 0.3,
        steps: Int = 50,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<ConwaysGameOfLifeGenerator> {
        let generator = ConwaysGameOfLifeGenerator()
        let parameters = ConwaysGameOfLifeParameters(
            size: size,
            gridSize: gridSize,
            initialDensity: initialDensity,
            steps: steps
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Langton's Ant Fractal

    static func createLangtonsAnt(
        gridSize: Int = 200,
        steps: Int = 10000,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<LangtonsAntGenerator> {
        let generator = LangtonsAntGenerator()
        let parameters = LangtonsAntParameters(
            size: size,
            gridSize: gridSize,
            steps: steps
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Cantor Dust Fractal

    static func createCantorDust(
        depth: Int = 4,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<CantorDustGenerator> {
        let generator = CantorDustGenerator()
        let parameters = CantorDustParameters(
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Menger Cube Fractal

    static func createMengerCube(
        depth: Int = 2,
        projectionType: String = "isometric",
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<MengerCubeGenerator> {
        let generator = MengerCubeGenerator()
        let parameters = MengerCubeParameters(
            size: size,
            depth: depth,
            projectionType: projectionType
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Simplex Noise Fractal

    static func createSimplexNoise(
        scale: Double = 50.0,
        octaves: Int = 4,
        persistence: Double = 0.5,
        lacunarity: Double = 2.0,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<SimplexNoiseGenerator> {
        let generator = SimplexNoiseGenerator()
        let parameters = SimplexNoiseParameters(
            iterations: 1000,
            size: size,
            scale: scale,
            octaves: octaves,
            persistence: persistence,
            lacunarity: lacunarity
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Voronoi Diagram Fractal

    static func createVoronoiDiagram(
        numSeeds: Int = 20,
        seedRadius: Double = 5.0,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<VoronoiDiagramGenerator> {
        let generator = VoronoiDiagramGenerator()
        let parameters = VoronoiDiagramParameters(
            iterations: 1000,
            size: size,
            numSeeds: numSeeds,
            seedRadius: seedRadius
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - DLA Fractal

    static func createDLA(
        numParticles: Int = 1000,
        stickiness: Double = 0.1,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<DLAGenerator> {
        let generator = DLAGenerator()
        let parameters = DLAParameters(
            iterations: 1000,
            size: size,
            numParticles: numParticles,
            stickiness: stickiness
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - IFS Fractal

    static func createIFS(
        depth: Int = 6,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<IFSGenerator> {
        let generator = IFSGenerator()
        let parameters = RecursiveFractalParameters(
            iterations: 50000,
            size: size,
            depth: depth
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }

    // MARK: - Fractal Flames Fractal

    static func createFractalFlames(
        numPoints: Int = 100_000,
        numVariations: Int = 3,
        colorSpeed: Double = 0.1,
        size: CGSize = CGSize(width: 600, height: 600)
    ) -> GenericFractalView<FractalFlamesGenerator> {
        let generator = FractalFlamesGenerator()
        let parameters = FractalFlamesParameters(
            iterations: 1000,
            size: size,
            numPoints: numPoints,
            numVariations: numVariations,
            colorSpeed: colorSpeed
        )
        return GenericFractalView(generator: generator, parameters: parameters)
    }
}

/// Registry for fractal generators
class FractalRegistry {
    static let shared = FractalRegistry()

    private var generators: [String: Any] = [:]

    private init() {
        registerDefaultGenerators()
    }

    func register<Generator: FractalGenerator>(_ generator: Generator, for name: String) {
        generators[name] = generator
    }

    func getGenerator(for name: String) -> Any? {
        return generators[name]
    }

    func getAvailableFractals() -> [String] {
        return Array(generators.keys)
    }

    private func registerDefaultGenerators() {
        register(MandelbrotGenerator(), for: "Mandelbrot")
        register(SierpinskiTriangleGenerator(), for: "SierpinskiTriangle")
        register(LorenzAttractorGenerator(), for: "LorenzAttractor")
        // Add more as they're implemented
    }
}

// MARK: - Fractal Types Enum

public enum FractalTypeEnum: String, CaseIterable {
    case mandelbrot = "Mandelbrot"
    case julia = "Julia"
    case sierpinskiTriangle = "Sierpinski Triangle"
    case sierpinskiCarpet = "Sierpinski Carpet"
    case lorenzAttractor = "Lorenz Attractor"
    case barnsleyFern = "Barnsley Fern"
    case kochSnowflake = "Koch Snowflake"
    case dragonCurve = "Dragon Curve"
    case burningShip = "Burning Ship"
    case henonAttractor = "Henon Attractor"
    case rosslerAttractor = "Rossler Attractor"
    case pythagoreanTree = "Pythagorean Tree"
    case boxCounting = "Box Counting"
    case levyCCurve = "Levy C Curve"
    case brownianMotion = "Brownian Motion"
    case diamondSquare = "Diamond-Square"
    case apollonianGasket = "Apollonian Gasket"
    case coastline = "Coastline"
    case fbm = "FBM"
    case heighwayDragon = "Heighway Dragon"
    case chuaCircuit = "Chua Circuit"
    case treeBranching = "Tree Branching"
    case snowFlake = "Snow Flake"
    case sierpinskiArrowhead = "Sierpinski Arrowhead"
    case romanescoBroccoli = "Romanesco Broccoli"
    case riverNetwork = "River Network"
    case plasmaFractal = "Plasma Fractal"
    case perlinNoise = "Perlin Noise"
    case logisticMap = "Logistic Map"
    case lightningPattern = "Lightning Pattern"
    case levyFlight = "Levy Flight"
    case mangerSponge = "Manger Sponge"
    case mandelbrot2 = "Mandelbrot2"
    case tricorn = "Tricorn"
    case hilbertCurve = "Hilbert Curve"
    case cantorSet = "Cantor Set"
    case newton = "Newton"
    case buddhabrot = "Buddhabrot"
    case peanoCurve = "Peano Curve"
    case gosperCurve = "Gosper Curve"
    case cliffordAttractor = "Clifford Attractor"
    case deJongAttractor = "De Jong Attractor"
    case gingerbreadmanMap = "Gingerbreadman Map"
    case conwaysGameOfLife = "Conway's Game of Life"
    case langtonsAnt = "Langton's Ant"
    case cantorDust = "Cantor Dust"
    case mengerCube = "Menger Cube"
    case simplexNoise = "Simplex Noise"
    case voronoiDiagram = "Voronoi Diagram"
    case dla = "DLA"
    case ifs = "IFS"
    case fractalFlames = "Fractal Flames"

    public var displayName: String {
        return rawValue
    }

    public func createView() -> AnyView {
        switch self {
        case .mandelbrot:
            return AnyView(FractalFactory.createMandelbrot())
        case .sierpinskiTriangle:
            return AnyView(FractalFactory.createSierpinski())
        case .sierpinskiCarpet:
            return AnyView(FractalFactory.createSierpinskiCarpet())
        case .lorenzAttractor:
            return AnyView(FractalFactory.createLorenz())
        case .julia:
            return AnyView(FractalFactory.createJulia())
        case .kochSnowflake:
            return AnyView(FractalFactory.createKochSnowflake())
        case .dragonCurve:
            return AnyView(FractalFactory.createDragonCurve())
        case .burningShip:
            return AnyView(FractalFactory.createBurningShip())
        case .henonAttractor:
            return AnyView(FractalFactory.createHenonAttractor())
        case .barnsleyFern:
            return AnyView(FractalFactory.createBarnsleyFern())
        case .rosslerAttractor:
            return AnyView(FractalFactory.createRosslerAttractor())
        case .pythagoreanTree:
            return AnyView(FractalFactory.createPythagoreanTree())
        case .boxCounting:
            return AnyView(FractalFactory.createBoxCounting())
        case .levyCCurve:
            return AnyView(FractalFactory.createLevyCCurve())
        case .brownianMotion:
            return AnyView(FractalFactory.createBrownianMotion())
        case .diamondSquare:
            return AnyView(FractalFactory.createDiamondSquare())
        case .apollonianGasket:
            return AnyView(FractalFactory.createApollonianGasket())
        case .coastline:
            return AnyView(FractalFactory.createCoastline())
        case .fbm:
            return AnyView(FractalFactory.createFBM())
        case .heighwayDragon:
            return AnyView(FractalFactory.createHeighwayDragon())
        case .chuaCircuit:
            return AnyView(FractalFactory.createChuaCircuit())
        case .treeBranching:
            return AnyView(FractalFactory.createTreeBranching())
        case .snowFlake:
            return AnyView(FractalFactory.createSnowFlake())
        case .sierpinskiArrowhead:
            return AnyView(FractalFactory.createSierpinskiArrowhead())
        case .romanescoBroccoli:
            return AnyView(FractalFactory.createRomanescoBroccoli())
        case .riverNetwork:
            return AnyView(FractalFactory.createRiverNetwork())
        case .plasmaFractal:
            return AnyView(FractalFactory.createPlasmaFractal())
        case .perlinNoise:
            return AnyView(FractalFactory.createPerlinNoise())
        case .logisticMap:
            return AnyView(FractalFactory.createLogisticMap())
        case .lightningPattern:
            return AnyView(FractalFactory.createLightningPattern())
        case .levyFlight:
            return AnyView(FractalFactory.createLevyFlight())
        case .mangerSponge:
            return AnyView(FractalFactory.createMangerSponge())
        case .mandelbrot2:
            return AnyView(FractalFactory.createMandelbrot2())
        case .tricorn:
            return AnyView(FractalFactory.createTricorn())
        case .hilbertCurve:
            return AnyView(FractalFactory.createHilbertCurve())
        case .cantorSet:
            return AnyView(FractalFactory.createCantorSet())
        case .newton:
            return AnyView(FractalFactory.createNewton())
        case .buddhabrot:
            return AnyView(FractalFactory.createBuddhabrot())
        case .peanoCurve:
            return AnyView(FractalFactory.createPeanoCurve())
        case .gosperCurve:
            return AnyView(FractalFactory.createGosperCurve())
        case .cliffordAttractor:
            return AnyView(FractalFactory.createCliffordAttractor())
        case .deJongAttractor:
            return AnyView(FractalFactory.createDeJongAttractor())
        case .gingerbreadmanMap:
            return AnyView(FractalFactory.createGingerbreadmanMap())
        case .conwaysGameOfLife:
            return AnyView(FractalFactory.createConwaysGameOfLife())
        case .langtonsAnt:
            return AnyView(FractalFactory.createLangtonsAnt())
        case .cantorDust:
            return AnyView(FractalFactory.createCantorDust())
        case .mengerCube:
            return AnyView(FractalFactory.createMengerCube())
        case .simplexNoise:
            return AnyView(FractalFactory.createSimplexNoise())
        case .voronoiDiagram:
            return AnyView(FractalFactory.createVoronoiDiagram())
        case .dla:
            return AnyView(FractalFactory.createDLA())
        case .ifs:
            return AnyView(FractalFactory.createIFS())
        case .fractalFlames:
            return AnyView(FractalFactory.createFractalFlames())
        default:
            return AnyView(Text("Not implemented yet"))
        }
    }
}
