//
//  HP_TriviaApp.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 11/11/2024.
//

import SwiftUI

@main
struct HP_TriviaApp: App {
    @StateObject private var store = Store()
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(gameViewModel)
                .task{
                    await store.loadProducts()
                    gameViewModel.loadScores()
                    store.loadStatus()
                }
        }
    }
}
