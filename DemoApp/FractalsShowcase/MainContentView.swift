//
//  MainContentView.swift
//  FractalsShowcase
//
//  Created by Mateusz Kosikowski 2021.
//

import SwiftUI

struct MainContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Original ContentView (Old Architecture)
            ContentView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Original")
                }
                .tag(0)

            // New Generator ContentView (New Architecture)
            NewGeneratorContentView()
                .tabItem {
                    Image(systemName: "gearshape.2")
                    Text("New Generator")
                }
                .tag(1)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    MainContentView()
}
