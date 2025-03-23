//
//  ring_aiApp.swift
//  ring-ai
//
//  Created by Sofyan Ajridi on 12/01/2025.
//

import SwiftUI

@main
struct ring_aiApp: App {
    @StateObject private var ringSearchVM = RingSearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ringSearchVM)
        }
    }
}
