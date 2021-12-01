//
//  FavoritesExampleApp.swift
//  FavoritesExample
//
//  Created by Aris Koxaras on 30/11/21.
//

import SwiftUI

@main
struct FavoritesExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ItemStore.shared)
        }
    }
}
